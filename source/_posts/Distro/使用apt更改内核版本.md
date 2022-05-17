---
title: 使用apt更改内核版本
date: 2020-01-19 20:11:18
---

有一些代码依赖于特定的内核版本，而如果安装系统之后发现内核版本对不上之后就要更换内核。重新编译内核十分麻烦而且耗时，万幸的是debian系列（ubuntu、mint等）可以使用apt来方便地更改内核版本。

先执行
```
apt-cache search linux-image-4.*
```
获得仓库中有哪些版本的第4代linux内核。

例如如果想要更换内核版本为4.15.0-70，那么就执行以下命令

```shell
sudo apt-get install linux-headers-4.15.0-70
sudo apt-get install linux-headers-4.15.0-70-generic
sudo apt-get install linux-modules-4.15.0-70-generic
sudo apt-get install linux-image-4.15.0-70-generic
sudo apt-get install linux-modules-extra-4.15.0-70-generic
```

其中有一些包可以不用装。这里为了保险就全装上了。

然后重启，在系统选择界面选高级（Advanced）模式，就可以看到之前安装的内核了。点击之即可进入这个内核所支持的系统。

```shell
uname -r
```

```
4.15.0-70-generic
```
