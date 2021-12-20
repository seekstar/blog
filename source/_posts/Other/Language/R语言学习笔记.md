---
title: R语言学习笔记
date: 2020-11-09 12:44:03
---

# 提取出某列满足条件的行
比方提取出mtcars中gear为3的行：
```R
mtcars[mtcars$gear == 3,]
```
# 判断某值是否在某集合中
用```%in%```
```
> 4 %in% 3:5
[1] TRUE
```
# 将数字list转化为字符串list
<https://bbs.pinggu.org/thread-4134694-1-1.html>
用```as.character```
```
> as.character(2:4)
[1] "2" "3" "4"
```

# 常见绘图参数
```R
?par
```
里面各种参数都有。比如可以调节大小（比如点的大小）的```cex```。
