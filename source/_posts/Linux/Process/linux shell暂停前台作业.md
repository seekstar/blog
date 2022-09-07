---
title: linux shell暂停前台作业
date: 2020-08-03 14:21:53
tags:
---

参考：<https://www.169it.com/tech-qa-linux/article-12409335996555240730.html>

ctrl+C是向前台进程组发送SIGINT，默认行为是终止前台作业。

但是很多时候我们只是想暂停。这时可以使用ctrl+Z，给前台进程组发送SIGTSTP，默认行为是停止直到下一个SIGCONT。

停止后在linux shell中输入fg后就可以给前台进程组发送SIGCONT，让其继续执行了。
输入bg可以让之前停止的前台进程组在后台运行。

fg: foreground，前台
bg: background，后台
