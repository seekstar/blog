---
title: xv6踩坑笔记
date: 2019-12-16 16:33:55
---

# lazy allocation
## test pgbug: FAILED
在系统调用函数(如sys_pipe)中，检测到致命错误（例如访问非法内存）时，不能直接用p->killed = 1，而是要return -1。

# mmap
scause 0x000000000000000d (load page fault)
sepc=0x0000000080007bb0 stval=0x0000000000000000
PANIC: kerneltrap

gdb调试了一波，发现在使用bd_malloc时跳入kerneltrap
明明实验三的时候还可以用bd_malloc，怎么现在用不了了？
看了一下代码，发现实验三中，kalloc的定义是这样的：
```c
void *
kalloc(void)
{
  return bd_malloc(PGSIZE);
}
```
然后实验九中是这样的：
```c
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  release(&kmem.lock);

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}
```
所以实验九中不能用bd_malloc（吐血
