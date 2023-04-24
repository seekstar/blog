---
title: grub检测其他操作系统
date: 2023-04-22 13:07:14
tags:
---

新版本grub出于安全原因默认禁用了检测其他操作系统的功能。如果要开启这个功能的话，需要在`/etc/default/grub`里添加`GRUB_DISABLE_OS_PROBER=false`。此外，很坑的是，这个功能是依赖`os-prober`命令的，因此需要先安装`os-prober`才行：

```shell
# ArchLinux
sudo pacman -S os-prober
```

然后尝试一下：

```shell
sudo os-prober
```

没问题的话再跑`grub-mkconfig`就会检测其他操作系统了。

