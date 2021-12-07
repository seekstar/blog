---
title: Centos8安装ZFS
date: 2021-05-04 17:21:05
---

查看当前centos版本号
```shell
cat /etc/redhat-release
```
```
CentOS Linux release 8.3.2011
```
然后
```shell
sudo dnf install https://zfsonlinux.org/epel/zfs-release.<dist>.noarch.rpm
gpg --import --import-options show-only /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
```
其中```<dist>```换成版本号，比如我这个就是```el8_3```。

# DKMS
```shell
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf config-manager --set-enabled powertools
```
（上面这段是不是可以不要？）

```shell
sudo dnf install epel-release
sudo dnf install kernel-devel zfs
```
要等好久。

# 插入内核模块
```shell
/sbin/modprobe zfs
```
检查一下是否安装成功：
```shell
sudo zfs list
```
显示这个就说明装好了。
```
no datasets available
```

# 参考文献
官方教程：<https://openzfs.github.io/openzfs-docs/Getting%20Started/RHEL%20and%20CentOS.html>
<https://github.com/openzfs/zfs>
<https://www.howtogeek.com/175159/an-introduction-to-the-z-file-system-zfs-for-linux/>
