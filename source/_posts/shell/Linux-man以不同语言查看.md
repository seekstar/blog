---
title: Linux man以不同语言查看
date: 2022-02-17 21:29:36
tags:
---

查看本地安装的语言：

```shell
locale -a
```

输出：

```text
C
en_US.utf8
POSIX
zh_CN.utf8
```

以中文查看：

```shell
man -Lzh_CN man
```

以英文查看：

```shell
man -Len_US man
# 直接写en好像也可以
man -Len man
```

如果是未知语言，会自动fallback到英文：

```shell
man -Ltest man
```

其实前面的```locale -a```只是起到确定```-L```参数的值的作用，不在里面的其实也可以，只要安装了对应的man pages，比如意大利语：

```shell
man -Lit man
```

来源：<https://unix.stackexchange.com/questions/283660/how-to-change-the-language-for-man-command>
