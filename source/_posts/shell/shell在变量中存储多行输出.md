---
title: shell在变量中存储多行输出
date: 2021-05-18 23:29:44
---

其实直接
```shell
res=$(echo -e "abc\ndef")
```
即可。但是输出时不能直接
```shell
echo $res
```
这样只会输出
```
abc def
```

正确做法是
```shell
echo "$res"
```
```
abc
def
```

原文：<https://stackoverflow.com/questions/613572/capturing-multiple-line-output-into-a-bash-variable/613580>
