---
title: CentOS使用笔记
date: 2023-07-18 21:35:36
tags:
---

## glibc升级失败进不去系统的解决方法

以CentOS 8 stream为例。

因为CentOS的dvd1做的启动盘貌似没有live模式，所以得做一个Debian的live启动盘。进入Debian的live环境之后，先挂载根目录到`/mnt`：

```shell
sudo mount /dev/mapper/cl-root /mnt
```

然后下载glibc的包，这里以`glibc-2.28.228`为例：

```shell
wget https://mirrors.tuna.tsinghua.edu.cn/centos/8-stream/baseos/x86_64/os/packages/glibc-2.28-228.el8.x86_64.rpm
wget https://mirrors.tuna.tsinghua.edu.cn/centos/8-stream/baseos/x86_64/os/packages/glibc-common-2.28-228.el8.x86_64.rpm
wget https://mirrors.tuna.tsinghua.edu.cn/centos/8-stream/baseos/x86_64/os/packages/glibc-langpack-en-2.28-228.el8.x86_64.rpm
```

安装：

```shell
rpm -ivh --nodeps --root=/mnt glibc-*.rpm
```
