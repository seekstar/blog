---
title: bash获取exit code
date: 2023-06-11 15:47:57
tags:
---

`echo $?`可以获取上一条命令的exit code。

但是如果bash脚本中设置了`set -e`，那么如果命令的exit code不为0，当前bash脚本会直接退出。这种情况下如果要获取命令的exit code而不退出，需要让该命令在一个新的shell中执行：

```shell
set -e
ret=$(bash -c 'bash test2.sh; echo $?')
echo $ret
```
