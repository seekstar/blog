---
title: Linux shell向进程组发信号
date: 2022-06-09 13:26:40
tags:
---

PID为负表示这其实是PGID (Process Group ID)，向这个PGID中的所有进程发信号。

例：向`34325`进程组的所有进程发送`SIGTERM`：

```shell
kill -TERM -34325
```

来源：<https://stackoverflow.com/questions/392022/whats-the-best-way-to-send-a-signal-to-all-members-of-a-process-group>

## 查看进程组的方法

`ps -efj`。来源：[PID, PPID, PGID与SID](https://blog.csdn.net/Justdoit123_/article/details/101347971)

## 在一个新的进程组中运行命令

脚本里运行命令时，默认会继承当前进程组。但我们也可以让命令在一个新的进程组中执行。

### `setsid`

```sh
setsid command args...
```

如果是pipeline命令：

```sh
setsid sh -c "command1 | command2 | command3"
```

### bash: `set -m`

对于`bash`，如果要让命令在新的进程组中运行，可以在脚本中先开启`"monitor mode" (job control)`：

```shell
set -m
```

来源：<https://unix.stackexchange.com/questions/529764/how-can-i-start-a-bash-script-in-its-own-process-group>

局部生效：

```shell
(set -m; sleep 10)
```

来源：<https://stackoverflow.com/questions/6549663/how-to-set-process-group-of-a-shell-script>

在后台运行：

```shell
(set -m; sleep 10 &)
```

打印生成的后台进程的进程号：

```shell
(set -m; sleep 10 & echo $! )
```

注意`&`本身已经表示了语句的结尾，所以`&`后面如果再加`;`的话`bash`会报错：

```text
$ (set -m; sleep 10 &; echo $! )
bash: syntax error near unexpected token `;'
```

不过zsh允许空语句`;`，所以不会报错。

将生成的后台进程的进程号保存到变量：

```shell
pid=$(set -m; sleep 10 > /dev/null & echo $! )
echo $pid
```

command substitution会等待所有stdout的writer关闭管道，因此要将`sleep 10`的stdout重定向到`/dev/null`。来源：<https://stackoverflow.com/questions/51507719/why-is-this-command-substitution-waiting-for-the-background-job-to-finish>

需要注意的是，如果命令需要读取管道，那么在管道被写之前，即使命令是后台命令，这个后台进程也不会被创建。例如：

```sh
mkfifo /tmp/pipe
pid=$(set -m; sleep 10 < /tmp/pipe > /dev/null & echo $!)
echo $pid
```

会卡死主shell。只有在另一个shell里往管道里写数据：`echo test > /tmp/pipe`，`sleep 10`的后台进程才会被创建，`echo $pid`才会被执行。

同样，如果命令需要写管道，那么在管道被读之前，后台进程也不会被创建：

```sh
mkfifo /tmp/pipe
pid=$(set -m; sleep 10 > /tmp/pipe & echo $!)
echo $pid
```

只有在另一个shell读取管道：`cat /tmp/pipe`，`sleep 10`的后台进程才会被创建。

这可能跟管道的实现有关，只有当读写进程都就位之后进程才会被创建。

在同一个shell里创建读写进程，我们可以将创建进程的部分放入一个单独的进程里：

```sh
mkfifo /tmp/pipe
pid=$(set -m; (sleep 10 > /tmp/pipe) > /dev/null & echo $!)
echo $pid
pid=$(set -m; (sleep 10 < /tmp/pipe) > /dev/null & echo $!)
echo $pid
```
