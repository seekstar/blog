---
title: linux常见问题及解决方案个人笔记
date: 2020-03-07 22:31:37
---

## su：鉴定故障

```text
运行 gsmartcontrol (以用户 root)失败

与 gksu-run-helper 通信失败。

收到：
 su：鉴定故障
但期望的是：
 gksu: waiting
```

解决方案：

```shell
gksu-properties
```

将验证模式由su改为sudo。

参考：<https://forum.ubuntu.com.cn/viewtopic.php?t=307361>

## make[1]: *** /lib/modules/4.19.0-8-amd64/build: No such file or directory.  Stop.

参考：<https://www.tecmint.com/install-kernel-headers-in-ubuntu-and-debian/>

```shell
sudo apt install linux-headers-$(uname -r)
```
