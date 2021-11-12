---
title: linux shell判断某命令是否存在
date: 2020-04-10 21:38:02
tags:
---

参考：<https://blog.csdn.net/soindy/article/details/73794548>

例如判断apt命令是否存在
```shell
if command -v apt > /dev/null 2>&1; then
        APT=apt;
else
        APT=yum;
fi
echo $APT
```
