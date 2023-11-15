---
title: Linux获取线程CPU使用情况
date: 2023-11-14 21:11:30
tags:
---

相关：{% post_link shell/'Linux获取进程cpu使用率' %}

## CPU使用率

用`pidstat`:

```shell
pidstat -p 线程tid -H -u 间隔秒数 -t | awk '{if ($4 == 线程tid) print $9}'
```

## 累积CPU time

用`ps`:

```shell
ps -eT -o tid,cputimes | awk '{if ($1 == 线程tid) print $2}'
```

```text
       tid         TID       the unique number representing a dispatchable entity (alias lwp, spid).  This value
                             may also appear as: a process ID (pid); a process group ID (pgrp); a session ID for
                             the session leader (sid); a thread group ID for the thread group leader (tgid); and
                             a tty process group ID for the process group leader (tpgid).

       cputimes    TIME      cumulative CPU time in seconds (alias times).
```
