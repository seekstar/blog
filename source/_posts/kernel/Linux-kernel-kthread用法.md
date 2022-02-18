---
title: Linux kernel kthread用法
date: 2021-02-02 17:23:09
tags:
---

先说巨坑：如果`kthread_run`之后立马`kthread_stop`，`threadfn`可能不会被执行，`kthread_stop`返回`-EINTR`。这一点网上的教程很少有提及。
参考：<https://stackoverflow.com/questions/65987208/kthread-stopped-without-running>

# 创建线程
可以用`kthread_create`和`kthread_run`。
```c
/**
 * kthread_create - create a kthread on the current node
 * @threadfn: the function to run in the thread
 * @data: data pointer for @threadfn()
 * @namefmt: printf-style format string for the thread name
 * @arg...: arguments for @namefmt.
 *
 * This macro will create a kthread on the current node, leaving it in
 * the stopped state.  This is just a helper for kthread_create_on_node();
 * see the documentation there for more details.
 */
#define kthread_create(threadfn, data, namefmt, arg...) \
	kthread_create_on_node(threadfn, data, NUMA_NO_NODE, namefmt, ##arg)
```
```c
/**
 * kthread_run - create and wake a thread.
 * @threadfn: the function to run until signal_pending(current).
 * @data: data ptr for @threadfn.
 * @namefmt: printf-style name for the thread.
 *
 * Description: Convenient wrapper for kthread_create() followed by
 * wake_up_process().  Returns the kthread or ERR_PTR(-ENOMEM).
 */
#define kthread_run(threadfn, data, namefmt, ...)			   \
({									   \
	struct task_struct *__k						   \
		= kthread_create(threadfn, data, namefmt, ## __VA_ARGS__); \
	if (!IS_ERR(__k))						   \
		wake_up_process(__k);					   \
	__k;								   \
})
```
例子：
```c
struct task_struct *t1 = kthread_create(threadfn, data, "name%d", i);
if (!IS_ERR(t1))
	wake_up_process(t1);
```
```c
struct task_struct *t2 = kthread_run(threadfn, data, "name%d", i);
```

# 终止线程
其实可以不终止线程，就让它跑完自己return，但是return之后它会自己`do_exit`，貌似会把`task_struct`释放掉，导致无法获取返回值。所以如果要获取返回值，必须要手动终止。

开头提到，如果`kthread_run`后直接`kthread_stop`，很容易导致在开始执行`threadfn`前被stop。所以可以传一个`struct completion`进去，然后在`threadfn`开头`complete`，而调用者`wait_for_completion`，然后再`kthread_stop`就好了。

例子
```c
// test1.c
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/delay.h>
#include <linux/kthread.h>
#include <linux/sched.h>
#include <linux/semaphore.h>
#include <linux/spinlock.h>

MODULE_LICENSE("GPL");

struct para {
	const char *msg;
	struct completion entered;
};
static int func(void *__para)
{
	struct para *para = (struct para *)__para;
	complete(&para->entered);
	// Do something here

	/* Wait for kthread_stop */
	set_current_state(TASK_INTERRUPTIBLE);
	while (!kthread_should_stop()) {
		schedule();
		set_current_state(TASK_INTERRUPTIBLE);
	}
	set_current_state(TASK_RUNNING);
	printk("%s %s return\n", __func__, para->msg);
	return 0;
}
static int __init start_init(void)
{
	struct task_struct *t1;
	struct para para;
	int ret;

	printk(KERN_INFO "Thread Creating...\n");
	para.msg = "t1";
	init_completion(&para.entered);
	t1 = kthread_run(func, &para, "t1");
	if (IS_ERR(t1)) {
		WARN_ON(1);
		return 0;
	}
	wait_for_completion(&para.entered);
	ret = kthread_stop(t1);
	printk("t1 stopped, exit code %d\n", ret);

	return 0;
}

static void __exit end_exit(void)
{
}

module_init(start_init)
module_exit(end_exit)
```

Makefile:

```Makefile
obj-m += test1.o
all:
        $(MAKE) -C /lib/modules/$(shell uname -r)/build M=`pwd`
clean:
        $(MAKE) -C /lib/modules/$(shell uname -r)/build M=`pwd` clean
```

跑一下

```shell
make
sudo insmod test1.ko
```

输出：

```
[379459.914962] Thread Creating...
[379459.915181] func t1 return
[379459.915187] t1 stopped, exit code 0
```

# 清理`kthread_create`的线程
为什么要在执行`threadfn`前检查一下`kthread_should_stop`呢？就是为了在`kthread_create`之后，在`wake_up_process`之前，可以取消运行这个线程。

一个典型的应用就是需要申请很多个线程时，先申请，再`wake_up_process`。如果申请失败，就直接`kthread_stop`其他申请成功的线程，它们就在运行`threadfn`前就停掉，防止了资源的浪费。

例子
```shell
static int __init start_init(void)
{
    struct task_struct *t1 = NULL, *t2 = NULL;
    struct para para1, para2;
    int ret;

    printk(KERN_INFO "Thread Creating...\n");
    para1.msg = "t1";
    para2.msg = "t2";
    init_completion(&para1.entered);
    init_completion(&para2.entered);
    t1 = kthread_create(func, &para1, "t1");
    if (IS_ERR(t1)) {
        WARN_ON(1);
        ret = PTR_ERR(t1);
        t1 = NULL;
        goto cancel;
    }
    t2 = kthread_create(func, &para2, "t2");
    if (IS_ERR(t2)) {
        WARN_ON(1);
        ret = PTR_ERR(t2);
        t2 = NULL;
        goto cancel;
    }
    wake_up_process(t1);
    wake_up_process(t2);
    wait_for_completion(&para1.entered);
    ret = kthread_stop(t1);
    printk("t1 stopped, exit code %d\n", ret);
    wait_for_completion(&para2.entered);
    ret = kthread_stop(t2);
    printk("t2 stopped, exit code %d\n", ret);

    return 0;
cancel:
    if (t1)
        printk("t1 stopped, exit code %d\n",
            kthread_stop(t1));
    if (t2)
        printk("t2 stopped, exit code %d\n",
            kthread_stop(t2));

    return ret;
}
```
跑一下
```
[ 1689.490109] Thread Creating...
[ 1689.490478] func t1 return
[ 1689.490484] t1 stopped, exit code 0
[ 1689.490487] func t2 return
[ 1689.490491] t2 stopped, exit code 0
```
可以看到正常运行，然后返回。

在`wake_up_process(t1);`前插入`goto cancel;`，看看cancel的效果怎么样
```
[ 1793.442321] Thread Creating...
[ 1793.442840] t1 stopped, exit code -4
[ 1793.442851] t2 stopped, exit code -4
```
可以看到`threadfn`（在这里是`func`）没有运行，直接就stop了，并且返回了`-4`，查表知它就是`-EINTR`。
# 参考文献
do_exit貌似会自己清理task_struct:
<https://stackoverflow.com/questions/10177641/proper-way-of-handling-threads-in-kernel>

