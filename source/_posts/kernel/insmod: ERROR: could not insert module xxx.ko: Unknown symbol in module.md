---
title: "insmod: ERROR: could not insert module xxx.ko: Unknown symbol in module"
date: 2020-11-13 19:47:03
---

意思是有些符号（大概率是函数）声明了但是未定义。
```shell
sudo dmesg
```
就可以看到是哪个符号出问题了。
