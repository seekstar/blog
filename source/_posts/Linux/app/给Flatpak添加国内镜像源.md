---
title: 给flatpak添加国内镜像源
date: 2021-12-30 20:24:23
tags:
---

如果已经添加了flathub的话，就用remote-modify修改：

```shell
sudo flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub
```

参考：<https://xuyiyang.com.cn/archives/%E7%BB%99flatpak%E6%B7%BB%E5%8A%A0%E5%9B%BD%E5%86%85%E9%95%9C%E5%83%8F%E6%BA%90>

如果没有的话，就用remote-add添加：

```shell
sudo flatpak remote-add flathub https://mirror.sjtu.edu.cn/flathub/flathub.flatpakrepo
```
