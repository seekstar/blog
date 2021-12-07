---
title: shell去掉输出的末尾换行符
date: 2021-08-19 17:37:27
---

用```echo -n $(you_command)```即可。

比如：

```shell
echo -n $(echo test)
```

输出：

```
[searchstar@localhost ~]$ echo -n $(echo test)
test[searchstar@localhost ~]$
```
