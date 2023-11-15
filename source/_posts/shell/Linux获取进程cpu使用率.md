---
title: Linux获取进程cpu使用率
date: 2023-07-01 14:38:32
tags:
---

## pidstat (推荐)

```shell
pidstat -p 进程PID -H -u 间隔秒数 | awk '{if(NR>3){print $1,$8}}'
```

- `-H`: Display timestamp in seconds since the epoch.
- `-u`: Report CPU utilization.
- `NR>3`: 第四行开始才是有效输出。

awk可能需要加上`fflush(stdout)`: {% post_link shell/'awk-fflush' %}

## top

```shell
top -b -p 进程PID -d 间隔秒数
```

`-b`: Batch mode.

配合`awk`等可以把CPU使用率给提取出来，但是由于CPU使用率在哪一列是根据`~/.toprc`确定的，所以要做到portable很麻烦。

## ps (不推荐)

注意，这个方法只能用来获取整个进程生命周期的平均CPU使用率。

```shell
ps -q 进程PID -o %cpu
```

输出：

```text
%CPU
52.3
```

不过用来获取累积CPU time的秒数挺好用的：

```shell
ps -q 进程PID -o cputimes
```

同理也可以获取进程的内存占用：

```shell
ps -q 进程PID -o %cpu,%mem
```

输出：

```text
%CPU %MEM
52.2  4.1
```

这个内存占用应该是瞬时的。

```text
       %cpu        %CPU      cpu utilization of the process in "##.#" format.  Currently, it is the CPU time used
                             divided by the time the process has been running (cputime/realtime ratio), expressed
                             as a percentage.  It will not add up to 100% unless you are lucky.  (alias pcpu).

       %mem        %MEM      ratio of the process's resident set size  to the physical memory on the machine,
                             expressed as a percentage.  (alias pmem).

       cputimes    TIME      cumulative CPU time in seconds (alias times).
```

## 参考文献

<https://www.baeldung.com/linux/process-periodic-cpu-usage>
