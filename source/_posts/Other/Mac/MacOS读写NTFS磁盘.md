---
title: MacOS读写NTFS磁盘
date: 2021-08-26 11:38:45
---

看这里：[Mac OS mojave, Big Sur 内置读写NTFS](https://blog.csdn.net/github_36326955/article/details/111473893)

补充一下，由于finder里没有这个磁盘了，要卸载的话只能这样：

```shell
sudo umount /Volumes/标签
```
