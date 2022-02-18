---
title: cppunit for linux入门笔记
date: 2020-05-25 12:20:48
tags:
---

我是用apt安装的
```shell
sudo apt install -y libcppunit-dev libcppunit-doc
mkdir -p ~/doc
ln -s /usr/share/doc/libcppunit-doc/html/index.html ~/doc/cppunit.html
```
安装的版本是`1.13.2-2.1`。

然后
```shell
firefox ~/doc/cppunit.html
```
就可以在浏览器打开安装的文档了。

文档里有一个Money, a step by step example，但是在我这跑不通，这里记录一下解决方法。
- 把`configure.in`改成`configure.ac`。
- 把`#include "stdafx.h"`删掉。
- `aclocal -I /usr/share/aclocal`
- `touch NEWS README AUTHORS ChangeLog # To make automake happy`要放到`automake -a`前面。

最后执行`make check`就好了。
