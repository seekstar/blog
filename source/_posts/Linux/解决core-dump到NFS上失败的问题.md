---
title: 解决core dump到NFS上失败的问题
date: 2025-08-29 00:49:04
tags:
---

在NFS上跑一个程序然后segfault了，但是发现core文件是空的，然后`sudo dmesg | less`会发现有这样一行报错：

```text
Core dump to core aborted: cannot preserve file owner
```

要解决这个问题，可以使用`systemd-coredump`，让systemd来管理core dump：

```shell
# Debian 12
sudo apt install systemd-coredump
```

然后再跑一遍程序，等它`Segmentation fault (core dumped)`之后，core dump就被systemd接收了。

列出所有core dump:

```shell
coredumpctl list
```

列出所有由某可执行文件产生的core dump：

```shell
coredumpctl list /path/to/binary
```

把最近的core dump保存为文件`core`：

```shell
coredumpctl dump /path/to/binary -o core
```

删除所有core dump：

```shell
# 不知道为什么 sudo systemd-tmpfiles --clean 没用
sudo rm -f /var/lib/systemd/coredump/*
```
