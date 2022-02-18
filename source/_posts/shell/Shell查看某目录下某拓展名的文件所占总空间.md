---
title: Shell查看某目录下某拓展名的文件所占总空间
date: 2022-02-17 21:01:39
tags:
---

比如要查看`目录`下png文件占用的总空间：

```shell
find 目录 -type f -name "*.png" -print0 | xargs -0r du -ch
```

输出的最后一行就是占用的总空间。

以下来自`man find`：

`-type f`: 只查找普通文件。

`-print0`: 返回true；在标准输出打印文件全名，然后是一个null字符。这样可以使得处理 find 的输出的程序可以正确地理解带有换行符的文件名。

以下来自`man xargs`：

`-0`: 输入的文件名以 null 字符结尾，而不是空格，引号和反斜杠并不特殊处理 (所有字符都以字面意思解释)。禁止文件尾字符串，当另一个参数处理。当参数含有空格，引号，反斜杠时很方便。GNU find 的 -print0 选项产生适合这种模式的输出。

`-r`: 如果标准输入不包含任何非空格，将不运行命令。一般情况下，就算没有输入，命令也会运行一次。

来源：<https://unix.stackexchange.com/questions/308846/how-to-find-total-filesize-grouped-by-extension>
