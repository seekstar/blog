---
title: linux在octave中使用syms
date: 2019-12-20 16:59:59
---

先安装octave
```shell
sudo apt-get install octave
```
然后安装octave-symbolic库
```shell
sudo apt-get install octave-symbolic
```
这一步比较久，因为会自动下载一堆texlive什么的……
然后打开octave，输入
```matlab
pkg load symbolic
```
然后就可以使用syms了
