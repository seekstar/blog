---
title: linux kernel spinlock ticket汇编实现解读
date: 2020-12-01 13:30:19
---

spinlock的TAS、TTAS、ticket实现详见<https://blog.csdn.net/david_henry/article/details/5405093/>
queued spinlock详见<https://blog.csdn.net/y33988979/article/details/102676849>

下面详细介绍一下ticket的汇编实现。
内嵌汇编基础知识：<https://blog.csdn.net/qq_41961459/article/details/104518801>
# ticket
![在这里插入图片描述](linux%20kernel%20spinlock%20ticket汇编实现解读/20201201125717472.png)

```C
static __always_inline void __ticket_spin_lock(raw_spinlock_t *lock)
{
        short inc = 0x0100;	// next为1，owner为0

        asm volatile (
                LOCK_PREFIX "xaddw %w0, %1/n"	// xaddw指%w0 = %1和%1 += %w0同时进行。LOCK_PREFIX让xaddw是原子的。%w0表示第0个input (inc)的低16位。%1表示第1个input (lock->slock)。总的意思就是inc = lock->slock和++lock->slock.next同时进行。
                "1:/t"	// 标号
                "cmpb %h0, %b0/n/t"	// 比较inc的高8位(next)和低8位(owner)
                "je 2f/n/t"	// 如果相等则跳转到下面的标号2，其中f代表forward。
                "rep ; nop/n/t"	// 相当于pause。详见http://blog.sina.com.cn/s/blog_4bbf98c00100ysdq.html
                "movb %1, %b0/n/t"	// inc.owner = lock->slock.owner
                /* don't need lfence here, because loads are in-order */
                "jmp 1b/n"	// 跳到上面的标号1。其中b代表backward。
                "2:"
                : "+Q" (inc), "+m" (lock->slock)	// 两个input。+表示读写，Q在x86中表示寄存器a、b、c或者d。
                :
                : "memory", "cc");	// memory表示内存屏障（可是这里为什么要内存屏障呢？）。cc表示修改了标志寄存器。
} 
```
xaddw文档：<https://www.felixcloutier.com/x86/xadd>
Q在x86中表示寄存器a、b、c或者d：<https://www.cnblogs.com/cposture/p/9029043.html>
