---
title: github gist回滚版本
date: 2020-04-28 17:18:05
tags:
---

网页端好像没有回滚版本的功能。只能用命令行的样子。

进入gist仓库后，地址栏的地址形如
```shell
https://gist.github.com/你的用户名/XXXXX
```
将地址copy下来，打开终端，执行
```shell
git clone https://gist.github.com/你的用户名/XXXXX
```
即可把gist clone下来，然后reset然后push -f就好了。
