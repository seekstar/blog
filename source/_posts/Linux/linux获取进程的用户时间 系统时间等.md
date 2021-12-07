---
title: linux获取进程的用户时间 系统时间等
date: 2021-08-17 15:53:46
---

在```/proc/[pid]/stat```里有该进程的详细信息。其内容的解释可以在```man 5 proc```里查看（搜```/stat```）

相关部分如下：

```
(14) utime%lu
          Amount of time that this process has been scheduled in user mode, measured
          in  clock  ticks  (divide  by  sysconf(_SC_CLK_TCK)).  This includes guest
          time, guest_time (time spent running a virtual CPU, see  below),  so  that
          applications  that  are not aware of the guest time field do not lose that
          time from their calculations.

(15) stime  %lu
          Amount of time that this process has been scheduled in kernel  mode,  mea‐
          sured in clock ticks (divide by sysconf(_SC_CLK_TCK)).

(16) cutime  %ld
          Amount of time that this process's waited-for children have been scheduled
          in user mode, measured in clock ticks  (divide  by  sysconf(_SC_CLK_TCK)).
          (See  also  times(2).)   This includes guest time, cguest_time (time spent
          running a virtual CPU, see below).

(17) cstime  %ld
          Amount of time that this process's waited-for children have been scheduled
          in kernel mode, measured in clock ticks (divide by sysconf(_SC_CLK_TCK)).
```

一个进程里的所有线程的stat文件的内容都是一样的。

原文：<https://unix.stackexchange.com/questions/132035/obtain-user-and-kernel-time-of-a-running-process>
