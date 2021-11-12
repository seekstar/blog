---
title: linux shell递归修改指定文件夹内的文件的后缀名
date: 2020-05-18 18:57:21
tags:
---

参考：<https://blog.csdn.net/longxibendi/article/details/6387732>
上文的方法3在存在带有```.```的子文件夹时会出错。
本文使用sed去掉文件后缀名，可以解决这个问题。
```shell
#!/bin/bash
# Change the filename extensions of all files in the directory $1 from $2 to $3
find $1 -name "*.$2" | sed "s/.$2\$//g" | xargs -i -t mv {}.$2 {}.$3
```
# xargs
-i: 替换{}
-t: verbose
