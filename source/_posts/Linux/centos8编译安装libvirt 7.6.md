---
title: centos8编译安装libvirt 7.6
date: 2021-08-11 21:50:07
---

官方编译教程：<https://libvirt.org/compiling.html>
源码下载：<<https://libvirt.org/sources/>>

先进root用户（用sudo好像会出问题？）

```shell
sudo -s
```

# 安装依赖

```shell
yum install libtirpc-devel
meson configure --includedir /usr/include/tirpc/rpc/
```

libtirpc的rpc.h在`/usr/include/tirpc/rpc/rpc.h`，必须要手动告诉meson其目录位置，不然后面`ninja -C build`的时候会报错：rpc/rpc.h：没有那个文件或目录。

# 编译

```shell
yum install meson
meson build
ninja -C build
ninja -C build install
```

然后查看一下版本是不是更新了

```shell
virsh --version
libvirtd --version
```

```
7.6.0
libvirtd (libvirt) 7.6.0
```

我这里要重启一下终端libvirtd的版本才会变成最新的。

# 常见报错的处理
##  Program 'rpcgen portable-rpcgen' not found
```shell
yum install rpcgen
```

## Program 'rst2html5 rst2html5.py rst2html5-3' not found
```shell
yum install python3-docutils
```

用pip3安装的rst2html5好像不行。

参考：<https://www.mail-archive.com/libvirt-users@redhat.com/msg12432.html>

## Dependency "glib-2.0" not found
```shell
yum install glib2-devel
```

我这里如果是用普通用户跑的`meson build`就仍然报这个错，换成root用户就好了。

## Dependency "gnutls" not found
```shell
yum install gnutls-devel
```

## Dependency "libxml-2.0" not found

```shell
yum install libxml2-devel
```

## Problem encountered: You must install the pciaccess module to build with udev
```shell
yum install libpciaccess-devel
```

## rpc/rpc.h：没有那个文件或目录

```shell
yum install libtirpc-devel
meson configure --includedir /usr/include/tirpc/rpc/
```

好像要把源码目录删掉重新编译才行。

# 参考文献
[Centos7.6 下编译安装 Libvirt 7.5](https://blog.frytea.com/archives/546/)
<https://mesonbuild.com/Commands.html>
