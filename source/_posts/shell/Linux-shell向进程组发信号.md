---
title: Linux shell向进程组发信号
date: 2022-06-09 13:26:40
tags:
---

PID为负表示这其实是PGID (Process Group ID)，向这个PGID中的所有进程发信号。

例：向`34325`进程组的所有进程发送`SIGTERM`：

```shell
kill -TERM -34325
```

来源：<https://stackoverflow.com/questions/392022/whats-the-best-way-to-send-a-signal-to-all-members-of-a-process-group>

查看进程组的方法：`ps -efj`。来源：[PID, PPID, PGID与SID](https://blog.csdn.net/Justdoit123_/article/details/101347971)
