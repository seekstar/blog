---
title: Deepin卸载应用商店
date: 2022-12-25 12:37:07
tags:
---

Deepin为了保护用户，通过GUI无法卸载应用商店。但是可以用命令行卸载：

```shell
#sudo apt remove deepin-app-store deepin-home-appstore-daemon
sudo apt remove deepin-home-appstore-daemon
```
