---
title: Ubuntu修复/boot满了导致apt坏掉的问题
date: 2022-08-22 17:23:58
tags:
---

如果apt在安装某个包需要往`/boot`里装新内核，但是`/boot`又满了，那么apt在执行`install`, `purge`, `remove`, `autoremove`等命令时就会报依赖不满足的错。

可以采用这里的方案解决：<https://askubuntu.com/a/906046>

思路是先删除`/boot`里的旧内核，然后再`apt --fix-broken install`，重新安装这个包，即可解决问题。

由于旧内核是用`apt`安装的，不能直接`rm`删除，而是要先`dpkg --purge`删除，再`rm`删除。比如要删掉内核`5.13.0-40`，先找到对应的包：

```shell
apt list --installed | grep 5.13.0-40
```

输出：

```text
linux-headers-5.13.0-40-generic/focal-updates,focal-security,now 5.13.0-40.45~20.04.1 amd64 [installed,automatic]
linux-hwe-5.13-headers-5.13.0-40/focal-updates,focal-updates,focal-security,focal-security,now 5.13.0-40.45~20.04.1 all [installed,automatic]
linux-image-5.13.0-40-generic/focal-updates,focal-security,now 5.13.0-40.45~20.04.1 amd64 [installed,automatic]
linux-modules-5.13.0-40-generic/focal-updates,focal-security,now 5.13.0-40.45~20.04.1 amd64 [installed,automatic]
linux-modules-extra-5.13.0-40-generic/focal-updates,focal-security,now 5.13.0-40.45~20.04.1 amd64 [installed,automatic]
```

然后一次性全`purge`掉（逐个`purge`可能会出现循环依赖的问题）：

```shell
dpkg --purge linux-headers-5.13.0-40-generic linux-hwe-5.13-headers-5.13.0-40 linux-image-5.13.0-40-generic linux-modules-5.13.0-40-generic linux-modules-extra-5.13.0-40-generic
```

但是不知道为什么这一步并不会把内核文件删掉，因此再手动把文件删掉：

```shell
rm /boot/config-5.13.0-40-generic /boot/System.map-5.13.0-40-generic /boot/initrd.img-5.13.0-40-generic /boot/vmlinuz-5.13.0-40-generic
rm -r /usr/lib/modules/5.13.0-40-generic
```

然后更新grub：

```shell
update-grub
```

然后`apt --fix-broken install`就可以了。

## 讨论

其实如果能取消需要往`/boot`里安装新内核的包的安装更好：<https://askubuntu.com/questions/525088/how-to-delete-broken-packages-in-ubuntu>

```shell
sudo dpkg --remove --force-remove-reinstreq package_name
sudo apt-get update
```

但是不知道为什么虽然`apt update`是成功了，但是此后使用`apt install`的时候还是会报以前的错，就好像`apt`不知道那个包已经被删掉了一样。

而且下面的评论有人说`--force-remove-reinstreq`是个非常危险的选项。
