---
title: Linux内核获取当前CPU id
date: 2021-07-19 00:48:31
---

CPU id是[percpu变量](https://zhuanlan.zhihu.com/p/260986194)，调用```smp_processor_id()```可以取出。内核里对它的注释如下：

```
smp_processor_id() is safe if it's used in a preemption-off critical section, or in a thread that is bound to the current CPU.
```

所以除非是在绑定在CPU上的线程中使用，否则必须要先关抢占。内核已经封装了带关抢占的API：

```c
#define get_cpu()		({ preempt_disable(); smp_processor_id(); })
#define put_cpu()		preempt_enable()
```

典型用法：

```c
int cpuid = get_cpu();
// Do something
put_cpu()
```

参考文献：
<https://www.cnblogs.com/still-smile/p/11655239.html>
