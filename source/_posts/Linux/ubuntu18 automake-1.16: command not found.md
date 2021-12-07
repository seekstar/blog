---
title: "ubuntu18 automake-1.16: command not found"
date: 2021-07-01 18:32:46
---

但是ubuntu 18的automake是1.15的。其实不需要重新安装automake，直接跑下面的命令重新配置即可

```shell
autoscan
aclocal
autoconf
automake --add-missing
./configure
```
然后make就不会报这个错了。

原理见：<https://blog.csdn.net/hubbybob1/article/details/109244833>

~~反正我没看懂~~
