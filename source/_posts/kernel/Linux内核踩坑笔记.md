---
title: Linux内核踩坑笔记
date: 2019-11-22 22:23:45
---

## 关抢占

如果关了内核抢占，就不能睡眠。参考：<https://kernelnewbies.kernelnewbies.narkive.com/qF7CkZ9p/why-sleeping-not-allowed-after-preempt-disable>

### 内存屏障

关抢占需要内存屏障。原因：

<https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux-stable/+/386afc91144b36b42117b0092893f15bc8798a80%5E!/>

<https://stackoverflow.com/questions/33864903/why-a-barrier-is-enough-for-disabling-or-enabling-the-preemption>

但是这里说的是compiler barrier。讲道理应该不影响prefetch。

### GFP

不能睡眠，所以要用GFP_ATOMIC。

## 关中断

`copy_from_user`不能在关中断的情况下调用，因为访问用户态内存可能会引发fault。

## systemtap

systemtap embedded C踩坑笔记戳这：{% post_link Other/systemtap/'systemtap embedded C 踩坑笔记' %}

### task_struct的sibling字段

task_struct 的sibling字段指向的是一个侵入式双向循环链表的节点。这个链表头节点的pid是0。这个头节点并不是一个有效的task_struct，所以打印兄弟进程的时候要跳过这个头节点。（操作系统实验检查的时候被老师问为什么会打印出一个pid为0的进程，被问懵了）

pstree打印出来的东西，用{}括起来的是线程，如果用n*[{name}]的形式表示，就说明有n个线程。name表示主线程。这些线程被放到主线程的下一级，但是并不是它们所在的进程的子进程的兄弟进程，因为它们不是进程。（操作系统实验检查之后我改了代码，用pstree检查的时候发现好像少打印了进程，然后傻乎乎地去问老师然后受到了教育）
