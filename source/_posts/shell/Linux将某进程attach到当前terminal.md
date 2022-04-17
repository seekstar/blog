---
title: Linux将某进程attach到当前terminal
date: 2022-04-17 13:34:46
tags:
---

用reptyr可以实现：<https://github.com/nelhage/reptyr>

可以用包管理器安装：

```shell
sudo apt install reptyr
```

有些发行版可能禁用了`ptrace`，需要将其打开。临时打开（重启后恢复原样）：

```shell
sudo bash -c "echo 0 > /proc/sys/kernel/yama/ptrace_scope"
```

永久打开：编辑`/etc/sysctl.d/10-ptrace.conf`。但是我的ArchLinux上没有这个文件。。。

下面介绍一些应用场景。

## 将终端的一个无子进程的进程attach到另一个终端

先在一个普通terminal上运行一个命令，比如`top`，然后另外开一个终端（可以开在tmux里），运行`reptyr <PID>`，然后这个命令就会被转移到新的terminal上了。

这个方法对所有在某个终端里运行的前台进程和后台进程都适用。后台进程attach到新终端后会变成前台进程。

但是对`nohup`的后台进程没有作用，即使这个进程的父进程仍然是这个终端。会报这个错：

```text
[-] Target is not connected to a terminal.
    Use -s to force attaching anyways.
Unable to attach to pid 2354522: Inappropriate ioctl for device
```

## 将终端的一个有子进程的进程attach到另一个终端

`loop.sh`:

```shell
while true; do
	date
	sleep 1
done
```

然后在一个终端上`bash loop.sh`。

这时，如果在目标终端上执行`reptyr <PID>`，会报这个错：

```text
[-] Process 35789 (sleep) shares 35032's process group. Unable to attach.
(This most commonly means that 35032 has sub-processes).
Unable to attach to pid 35032: Invalid argument
```

相关讨论：<https://github.com/nelhage/reptyr/issues/84>

github上有人说`reptyr`的`steal TTY`的功能可以解决这个问题。我的理解是相当于直接把整个终端偷过来。用法：

```shell
# <PID>是进程PID，不是终端PID
reptyr -T <PID>
```

但是有时候好像没反应？这时好像ctrl+c然后再试就有机会成功。

偷TTY前后，`pstree -lp | grep bash`的结果对比如下（`l`表示打印长行，`p`表示打印PID）：

```text
之前
|-konsole(38654)-+-bash(38672)
|-konsole(40813)-+-bash(40835)---bash(40875)---sleep(41465)
之后
|-konsole(38654)-+-bash(38672)---reptyr(41662)
|-konsole(40813)-+-bash(40835)---bash(40875)---sleep(41686)
```

可以看到似乎并没有真的把这个进程变成新终端的子进程，而且把老终端关闭后新终端里的也会显示进程已退出。

上面的例子中，父终端是konsole，但是如果父终端是sshd的终端，那就需要以root身份执行才能把TTY偷过来了。TTY偷过来之后，原来的sshd终端就没响应了。奇妙的是，这是按`Enter` `~` `.`将原来的sshd终端退出之后，新终端里的进程并不会退出。

查看偷TTY前后以及断开ssh连接前后的`pstree -lp`的输出：

```text
偷TTY之前
systemd(1)─┬─
           ├─sshd(129723)─┬─
           │              ├─sshd(2083852)───sshd(2083858)───zsh(2083859)───tmux: client(2356318)
           │              ├─sshd(2355176)───sshd(2355182)───zsh(2355183)───bash(2356331)───sleep(2356373)
           ├─tmux: server(2354986)───zsh(2354987)───sudo(2355034)───reptyr(2355041)
偷TTY之后，断开ssh连接之前
systemd(1)─┬─
           ├─sshd(129723)─┬─
           │              ├─sshd(2083852)───sshd(2083858)───zsh(2083859)───tmux: client(2356318)
           │              ├─sshd(2355176)───sshd(2355182)───zsh(2355183)───bash(2356331)───sleep(2356783)
           ├─tmux: server(2354986)───zsh(2354987)───sudo(2355034)───reptyr(2355041)
断开ssh连接之后
systemd(1)─┬─
           ├─sshd(129723)─┬─
           │              ├─sshd(2083852)───sshd(2083858)───zsh(2083859)───tmux: client(2356318)
           ├─tmux: server(2354986)───zsh(2354987)───sudo(2355034)───reptyr(2355041)
           └─zsh(2355183)───bash(2356331)───sleep(2357023)
```

可以看到，偷TTY之后，进程的父终端(zsh)的父亲仍然没有改变，但是断开ssh连接之后，进程的父终端(zsh)的父亲变成init（1号进程）了。这可能是因为`Enter` `~` `.`并没有给子进程`zsh`发送`SIGHUP`，从而让它变成了孤儿进程，被init进程收养，因此新终端里的输出一直没有停。

总结一下，按照我的理解，偷TTY的做法相当于把进程的输入和输出重定向到新的终端，但是如果老的终端退出了，新终端里的输入输出会立即停止。但是在sshd下面的终端里的进程在sshd session被强制退出之后会变成孤儿进程，因此它不会被退出，可以正常在新终端里输入输出，就像它本来就在新终端一样。

## 另一个选择：reredirect

reredirect可以重定向任意进程的输出。如果只是想看输出，而不需要输入的话，可以试试：

{% post_link shell/'重定向正在运行的进程的输出' %}

## 参考文献

<https://superuser.com/questions/184047/bash-zsh-undoing-disown>
