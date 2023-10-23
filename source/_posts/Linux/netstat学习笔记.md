---
title: netstat学习笔记
date: 2023-10-22 17:06:46
tags:
---

## 持续输出

```text
   -c, --continuous
       This will cause netstat to print the selected information every second continuously.
```

## 用数字表示端口和host

```text
   --numeric, -n
       Show numerical addresses instead of trying to determine symbolic host, port or user names.
```

netstat默认会直接写出特殊端口的名字而不是端口号，比如`xxxx:nfs`，其中`nfs`就是NFS使用的端口`2049`。`netstat -n`就会显示`xxxx:2049`。
