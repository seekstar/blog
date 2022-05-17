---
title: pacman查看命令由哪个包提供
date: 2022-03-10 14:13:56
tags:
---

比如查看`dig`命令由哪个包提供。有两种方法：

## pacman -F

```shell
pacman -F dig
```

输出：

```text
extra/bind 9.16.25-1
    usr/bin/dig
community/epic4 2.10.10-2
    usr/share/epic/script/dig
```

## pacman -Fl

这个方法可以自己写正则表达式匹配，可能比较灵活一点：

```shell
pacman -Fl | grep -e "/dig$"
```

`-e`: 使用正则表达式。

`$`: 匹配行末。

输出：

```text
bind usr/bin/dig
epic4 usr/share/epic/script/dig
```

## 所以安装`bind`

```shell
sudo pacman -S bind
dig -v
```

```text
DiG 9.18.0
```

参考：[manjaro pacman查看已安装命令隶属于哪个包(arch应该也行)](https://blog.csdn.net/LoveZoeAyo/article/details/107096964)
