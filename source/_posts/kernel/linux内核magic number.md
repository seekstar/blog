---
title: linux内核magic number
date: 2020-02-24 19:04:48
---

参考：
<https://www.kernel.org/doc/html/v4.17/process/magic-number.html>
<https://en.wikipedia.org/wiki/Magic_number_(programming)>

结构体中的magic域可以在运行时判断结构体是否被“偷梁换柱”。如果在运行过程中发现某一结构体的magic域的值不等于这个结构体对应的magic number，说明发生了错误。

linux内核中的例子：
<linux/fs.h>
```c
struct fasync_struct {
	spinlock_t		fa_lock;
	int			magic;
	int			fa_fd;
	struct fasync_struct	*fa_next; /* singly linked list */
	struct file		*fa_file;
	struct rcu_head		fa_rcu;
};

#define FASYNC_MAGIC 0x4601
```
其中某个struct fasync_struct的magic域不等于0x4601，说明发生了错误。
