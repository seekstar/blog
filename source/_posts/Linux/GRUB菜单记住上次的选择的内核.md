---
title: GRUB菜单记住上次的选择的内核
date: 2022-01-11 18:17:27
tags:
---

在```/etc/default/grub```里加上：

```shell
# 原先要到advanced submenu选内核，把submenu禁用之后，选内核的menu entry就暴露在顶层menu了。
GRUB_DISABLE_SUBMENU=y
# 记住上次选的哪个menu entry
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
```

然后更新grub。deepin是

```shell
sudo update-grub
```

注意，deepin的系统设置里的“通用”那里的GRUB预览要重启之后才会更新。

然后重启系统，在GRUB菜单里选择想进入的内核，下次再开机就默认是那个内核了。

来源：<https://itsfoss.com/switch-kernels-arch-linux/>
