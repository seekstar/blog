---
title: Debian 10升级为Debian 11
date: 2022-05-01 00:18:32
tags:
---

可以通过ustc升级：官方教程：<https://mirrors.ustc.edu.cn/help/debian.html>

参考：<https://linux.cn/article-13647-1.html>

先把`/etc/apt/sources.list`里的所有行注释掉，然后加上

```text
deb http://mirrors.ustc.edu.cn/debian stable main contrib non-free
# deb-src http://mirrors.ustc.edu.cn/debian stable main contrib non-free
deb http://mirrors.ustc.edu.cn/debian stable-updates main contrib non-free
# deb-src http://mirrors.ustc.edu.cn/debian stable-updates main contrib non-free

deb http://mirrors.ustc.edu.cn/debian-security/ stable-security main non-free contrib
# deb-src http://mirrors.ustc.edu.cn/debian-security/ stable-security main non-free contrib
```

```shell
sudo apt update
sudo apt upgrade
# 或者 sudo apt full-upgrade?
```

验证一下是不是升级成功了：

```shell
cat /etc/os-release
```

```text
PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
NAME="Debian GNU/Linux"
VERSION_ID="11"
VERSION="11 (bullseye)"
VERSION_CODENAME=bullseye
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
```
