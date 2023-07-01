---
title: Linux获取进程cpu使用率
date: 2023-07-01 14:38:32
tags:
---

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
