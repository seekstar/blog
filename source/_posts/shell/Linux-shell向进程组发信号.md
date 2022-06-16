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

脚本里运行命令时，默认会继承当前进程组。如果要让命令在新的进程组中运行，可以在脚本中先开启`"monitor mode" (job control)`：

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
