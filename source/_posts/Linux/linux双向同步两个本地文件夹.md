---
title: linux双向同步两个本地文件夹
date: 2020-03-04 18:19:25
---

参考（膜大佬）：<https://blog.csdn.net/qq_26702065/article/details/52175560>

# 思路
- 用inotify监控文件夹，如果文件夹内有文件变化则输出变化情况
- 每当inotify检测到文件变化时，就调用unison，把当前文件夹的变化发给另一个文件夹
- 创建两个进程分别进行单向同步，从而变成了双向同步。

# 安装必要程序：
```shell
sudo apt install -y inotify-tools unison
```

# 单向同步
把下面的代码保存为syncto.sh
```shell
#/bin/bash

# $1: from
# $2: to
unison -batch $1 $2
inotifywait -mrq -e create,delete,modify,move $1 | while read line; do
        unison -batch $1 $2
done
```
- inotifywait
m: (monitor)一直监控
r: (recursive)递归监测目录
q: (quite)打印最少（只打印事件）
e: (event)只监测后面的特定事件
- unison
batch: 不问任何问题

# 双向同步
保存为syncboth.sh
```shell
nohup syncto.sh $1 $2 &
nohup syncto.sh $2 $1 &
```

然后
```shell
bash syncboth.sh dir1/ dir2/
```
其中dir1和dir2必须是绝对路径。

这样即可同步两个文件夹了（前提是两个文件夹没有冲突的部分。建议先手动同步一下两个文件夹，否则容易出问题）
