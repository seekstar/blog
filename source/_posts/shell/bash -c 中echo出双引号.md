---
title: bash -c 中echo出双引号
date: 2020-01-27 13:37:43
---

# bash -c后用双引号
```shell
bash -c "echo \"abc \\\" abc\""
```
## 输出
```
abc " abc
```
## 分析
由于双引号会对其中的内容进行解析，所以bash -c执行的内容被解析成
```
echo "abc \" abc"
```
然后bash会把引号中的内容作为第一个参数传给echo，其中`\"`会被bash解析成`"`。所以echo的第一个参数是
```
abc " abc
```
然后echo把第一个参数打印出来。

# bash -c后用单引号
```shell
bash -c 'echo "abc \" abc"'
```
单引号中的内容不会被解析，因此bash -c执行的内容直接就是
```
echo "abc \" abc"
```
后面的解析过程同上。
