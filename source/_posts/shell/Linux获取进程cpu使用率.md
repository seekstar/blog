---
title: Linux获取进程cpu使用率
date: 2023-07-01 14:38:32
tags:
---

## pidstat (推荐)

```shell
pidstat -p 进程PID 间隔秒数 -u | awk '{print $8}'
```

`-u`: Report CPU utilization.

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

## 参考文献

<https://www.baeldung.com/linux/process-periodic-cpu-usage>
