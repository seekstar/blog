---
title: Linux kernel spinlock
date: 2022-04-03 18:09:43
tags:
---

`spin_lock`的基本流程是先关抢占，然后一直spin，直到成功申请到锁。因此被spinlock保护的部分必须是atomic的，即必须一直执行到解锁，而不能睡眠。这是因为，一旦睡眠，切换到其他线程后，另一个线程可能会申请同一个锁，这样那个线程就会一直等待锁释放，因为持有锁的线程一直无法被调度。

因此被spinlock保护的部分：

- 不能调用`schedule()`

- 分配内存时只能用`GFP_ATOMIC`，不能用`GFP_KERNEL`

- 不能使用`mutex`

`spin_lock`不关中断，因此如果这个spinlock可能会被某个中断处理函数申请，那么就必须把中断也关了，即调用`spin_lock_irqsave`和`spin_unlock_irqrestore`。
