---
title: powershell学习笔记
date: 2020-03-26 21:39:21
---

参考：<http://www.bubuko.com/infodetail-1259207.html>

windows的powershell支持了许多linux命令。
与linux中使用方法基本相同的有：ls，rm、cat等。仍不支持的有touch、grep等。

与linux中使用方法不同的有：
# mv和cp
mv移动文件，cp复制文件。与linux不同的是，只能接收两个参数，第一个是原文件名或目录名，第二个参数是目的目录名或文件名。

# diff
参考：<https://blog.csdn.net/sxzlc/article/details/104880426>
要用cat把文件内容提取出来再比较
```shell
diff (cat a) (cat b)
```
