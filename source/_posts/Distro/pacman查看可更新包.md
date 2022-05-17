---
title: pacman查看可更新包
date: 2022-02-17 18:37:02
tags:
---

先更新源，获取最新应用的列表：

```shell
sudo pacman -Sy
```

查询可更新包：

```shell
pacman -Qu
```

yay同理：

```shell
yay -Sy
yay -Qu
```
