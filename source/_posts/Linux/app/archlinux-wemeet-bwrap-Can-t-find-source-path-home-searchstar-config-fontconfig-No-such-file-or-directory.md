---
title: >-
  archlinux wemeet bwrap: Can't find source path /home/searchstar/.config/fontconfig: No
  such file or directory
date: 2022-01-12 13:00:11
tags:
---

安装腾讯会议：

```shell
yay -S wemeet
```

可以从终端运行：

```shell
wemeet
```

但是报错：

```
bwrap: Can't find source path /home/searchstar/.config/fontconfig: No such file or directory
```

尝试新建这个目录：

```shell
mkdir ~/.config/fontconfig
```

就好了。。。
