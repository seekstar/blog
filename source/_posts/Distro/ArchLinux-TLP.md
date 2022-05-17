---
title: ArchLinux TLP
date: 2022-05-08 16:42:09
tags:
---

TLP是一款Linux的电源管理软件，装上可以省电。

```shell
sudo pacman -S tlp
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
# sudo tlp start
# 开机自启
sudo systemctl enable tlp.service
sudo systemctl start tlp.service
# Radio Device Wizard
sudo pacman -S tlp-rdw
sudo systemctl enable NetworkManager-dispatcher.service
sudo systemctl start NetworkManager-dispatcher.service
```

参考：

[如何在Linux中使用TLP快速增加和优化笔记本电脑的电池寿命？](https://www.bilibili.com/read/cv10529669/)

<https://wiki.archlinux.org/title/TLP_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>

<https://askubuntu.com/questions/841057/ubuntu-consumes-too-much-battery>
