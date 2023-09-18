---
title: Linux移动目录下所有文件或文件夹到另一个目录
date: 2023-09-18 11:24:17
tags:
---

## `find` + `xargs`

```shell
find a/ -mindepth 1 -maxdepth 1 -print0 | xargs -0 -r mv -t b/
```

`-mindepth 1 -maxdepth 1`: 只打印`a`的直接子文件和子目录。

`-print0`: 每项用`0`也就是`null`隔开，而不是以空格或者换行隔开。好处是这样可以支持带特殊字符的文件名和目录名。

`xargs -0`: 每项用`0`也就是`null`隔开。

`mv -t`: 第一个是目标，第二个是源。如果不带`-t`，那就是第一个是源，第二个是目标。

## （不推荐）`*`

```shell
mv a/* b/
```

缺点：

1. 假如源目录`a`是空的，就会报错，而且没法避免。

2. 不能移动`.`开头的文件或者目录。

## 参考文献

<https://askubuntu.com/questions/172629/how-do-i-move-all-files-from-one-folder-to-another-using-the-command-line>
