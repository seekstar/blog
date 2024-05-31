---
title: 解决Linux内存不足时ssh连不上的问题
date: 2024-05-31 22:29:49
tags:
---

## 关闭swap

开启swap之后，当内存不足时，Linux会把内存页swap到磁盘，导致内存的速度变成了磁盘的速度，ssh进程根本跑不动。因此建议在服务器上关闭swap。

## user space OOM killer

Linux在内存不足时不会第一时间进行OOM kill，而是会evict代码页，导致机器运行速度极慢，会出现无法ssh登录的情况。这时可以考虑使用用户态的OOM killer，在系统内存尚未完全耗尽时将最占内存的进程杀掉。我一般用`earlyoom`。
