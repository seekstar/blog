---
title: Linux kernel RCU
date: 2022-05-15 21:21:33
tags:
---

RCU的全称是Read-Copy Update。详解：[浅谈Linux内核源码RCU机制](https://zhuanlan.zhihu.com/p/479785704)。基本思路是不阻塞读，而更新的时候先把原来的数据复制一份，在副本上修改，修改完了一次性更新到受RCU保护的数据结构上。但是由于可能还有并发的reader在读老的副本，所以不能马上把老的副本释放掉。那么什么时候可以释放掉老的副本呢？

Linux内核做了一个很精妙的设计：读的时候不发生上下文切换，因此假如处理器发生了上下文切换，那么就说明读肯定已经完成了，而接下来的读都是读取新的数据。因此当所有处理器都完成了一次上下文切换之后，就可以确保所有可能读取老的副本的reader都已经退出了，这时就可以把老的副本释放掉。等待所有处理器完成一次上下文切换的时间就叫做grace period。用户态的RCU由于没有这些底层信息，因此采用的是别的实现方法：[Userspace RCU原理](https://blog.csdn.net/chenmo187J3X1/article/details/80992945)。

由于Linux内核的RCU假设了读的时候不发生上下文切换，因此一定要保证在占有`rcu_read_lock`时不发生上下文切换（不能睡眠）。如果一定要睡眠的话，可以使用SRCU (Sleepable RCU)。

等待所有处理器完成一次上下文切换可以用`synchronize_rcu()`，会导致睡眠。如果上下文不允许睡眠，或者对性能要求很高的话，可以用`call_rcu`注册回调函数，当所有处理器完成一次上下文切换系统会执行这些回调函数。`call_rcu`详解：[call_rcu()函数解析](http://blog.chinaunix.net/uid-20648784-id-1592810.html)

`call_rcu`的回调函数是在softirq context的，里面如果要用spinlock的话，要用`spin_lock_bh`上锁，`spin_unlock_bh`解锁，这样可以在spinlock里关掉软中断。`bh`是一个历史遗留名词，实际上指`softirq`。注意，如果一个spinlock既在softirq context里用了，又在user context里用了，那在user context里也要用`spin_lock_bh`和`spin_unlock_bh`上锁和解锁。

其他参考文献：

<https://www.kernel.org/doc/Documentation/RCU/checklist.txt>

<https://www.kernel.org/doc/htmldocs/kernel-locking/lock-user-bh.html>

<https://www.kernel.org/doc/html/latest/kernel-hacking/hacking.html#user-context>

<https://stackoverflow.com/questions/50379299/how-does-spin-lock-bh-work>
