---
title: 批量ssh执行命令
date: 2022-05-11 19:34:12
tags:
---

主要参考<https://www.tecmint.com/run-commands-on-multiple-linux-servers/>

## clusterssh

ArchLinux:

```shell
sudo pacman -S clusterssh
# 可以使用~/.ssh/config里的别名
cssh host1 host2 host3
cssh username@server1 username@server2 username@server3 
```

会为每个服务器开一个xterm窗口，此外还有一个小的只有一个输入条的窗口。在服务器对应的xterm输入的话，输入就只发送到这台服务器上，但是如果在输入条里输入的话，输入会发送到所有服务器，因此sudo输入密码甚至是使用vim都是可以的。

一些快捷键：

`Alt+n`: 把每个server的hostname粘贴到各个server。

`Ctrl+v`: 把剪切板里的内容粘贴到各个server。

完整版：`man cssh`

### 解决xterm的复制粘贴问题

xterm默认将选中的区域放入PRIMARY buffer，然后鼠标中键将PRIMARY buffer里的内容粘贴出来。但是系统剪切板是CLIPBOARD buffer。因此xterm不能跟系统剪切板交互。可以让xterm使用CLIPBOARD: <https://www.bianchengquan.com/article/450754.html>

然后选中区域就会被放入系统剪切板，鼠标中键就会把系统剪切板里的东西粘贴出来。

参考：[xterm 如何实现文字的复制粘贴](https://www.jianshu.com/p/078a1794731a)

## parallel-ssh

ArchLinux:

```shell
sudo pip3 install parallel-ssh
```

但是parallel-ssh命令找不到

```shell
sudo pip3 install pssh
```

提示version.VERSION没有。

参考：<https://www.cyberciti.biz/cloud-computing/how-to-use-pssh-parallel-ssh-program-on-linux-unix/>

## pdsh

ArchLinux:

```shell
yay -S pdsh
```
