---
title: Linux m4a转mp3
date: 2020-10-07 19:53:21
tags:
---

参考：<https://blog.csdn.net/weixin_30872671/article/details/97657821>

```shell
sudo apt install -y faad lame
faad -o - 新科学家英语.m4a | lame - 新科学家英语.mp3
```
