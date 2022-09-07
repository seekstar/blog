---
title: Linux将进程从当前终端detach
date: 2022-09-07 13:19:22
tags:
---

## 场景

ssh到服务器，开了进程，然后想把进程转移到后台执行，然后关掉ssh连接。相当于实现`nohup xxx &`的效果。

## 方法

`ctrl+z`，给进程发送SIGTSTP信号，让进程暂停。注意SIGTSTP信号是可以被捕获的，如果进程捕获并忽略了这个信号，那么可以尝试`kill -STOP pid`发送SIGSTOP信号，这个信号不能被捕获。

然后`jobs`查看被暂停的进程的编号，再`bg 编号`将这个进程放到后台执行，然后`disown 编号`将这个进程从任务列表中删掉，再`exit`退出当前终端。由于这个进程已经不在`jobs`里了，而且正在运行，因此不会对这个进程发送SIGHUP，而是让其变成孤儿进程，被init进程或者systemd进程收养，这样就实现了detach。

如果需要获取这个进程的输出，可以用reredirect：{% post_link shell/'重定向正在运行的进程的输出' %}

但是我没找到可以往这个进程的stdin里塞东西的方法。

## 例子

`loop.sh`:

```shell
while true; do
	date
	sleep 1
done
```

运行之：

```shell
bash loop.sh
```

按`ctrl+z`：

```text
[1]  + 60237 suspended  bash loop.sh
```

所以它的编号是`1`，进程号是`60237`。

也可以用`jobs`:

```text
[1]  + suspended  bash loop.sh
```

也显示其编号是`1`。

将其放到后台运行：

```shell
bg %1
```

输出：

```text
[1]  + 60237 continued  bash loop.sh
```

从jobs列表里删除：

```shell
disown %1
```

再`jobs`，打印的列表就是空的了。

此时`pstree -lp -s 60237`查看其父进程：

```text
systemd(1)───sshd(733)───sshd(57315)───sshd(57321)───zsh(57322)───bash(60237)───sleep(60330)
```

可以看到其父进程仍然没有改变。

然后`exit`退出当前终端，也就是上面的`zsh(57322)`，再`pstree -lp -s 60237`查看其父进程：

```text
systemd(1)───bash(60237)───sleep(60520)
```

可以看到变成孤儿进程，被1号进程收养了。

如果要获取其输出，可以用reredirect：`reredirect -m FILE 60237`，然后其`stdout`和`stderr`都被重定向到`FILE`了。详见：{% post_link shell/'重定向正在运行的进程的输出' %}

## 参考文献

{% post_link shell/'linux shell暂停前台作业' %}

<https://stackoverflow.com/questions/11886812/what-is-the-difference-between-sigstop-and-sigtstp>

<https://superuser.com/questions/1204006/how-to-find-ancestor-chain-of-a-process>
