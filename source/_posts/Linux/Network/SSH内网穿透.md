---
title: SSH内网穿透
date: 2022-02-17 19:00:54
tags:
---

比方说要把当前机器的8789端口映射到服务器的6100端口：

```shell
ssh -R 6100:localhost:8789 服务器IP
```

然后登录上服务器，就能通过6100端口连上这台机器了：

```shell
ssh localhost 6100
```

要允许所有IP都能通过服务器的6100端口连接上这台机器，需要在服务器上的`/etc/ssh/sshd_config`里加上

```text
GatewayPorts yes
```

然后重启`sshd`:

```shell
sudo systemctl restart sshd
```

（没试过`systemctl reload`可不可以）

改这个配置的原因见`man ssh`:

```text
     -R [bind_address:]port:host:hostport
     -R [bind_address:]port:local_socket
     -R remote_socket:host:hostport
     -R remote_socket:local_socket
     -R [bind_address:]port
...
             By default, TCP listening sockets on the server will be bound to the loop‐
             back interface only.  This may be overridden by specifying a bind_address.
             An empty bind_address, or the address ‘*’, indicates that the remote
             socket should listen on all interfaces.  Specifying a remote bind_address
             will only succeed if the server's GatewayPorts option is enabled (see
             sshd_config(5)).
```

一定要看英文的manual page，中文的好像很久没有更新了，不全。

然后再跑`ssh -R 6100:localhost:8789 服务器IP`，服务器的`6100`端口就可以接受任何IP的连接请求了。注意已有的`ssh -R`连接好像仍然看不到`GatewayPorts yes`，要先把原来的`ssh -R`的连接断开才行（在客户端`ctrl+c`或者采用后面描述的方法在服务器端把监听这个端口的`sshd`进程杀掉）。

## autossh

直接用ssh的话，断开连接之后并不会重连。所以使用autossh，在连接断开后重连。网上的教程通常是使用monitor port监测连接是否正常的，但是这样要在服务器上额外占用一个端口。其实`man autossh`已经提示我们可以用SSH自带的`ServerAliveInterval`和`ServerAliveCountMax`来检测连接是否正常，而且这可能是更好的方法：

```text
     -M port[:echo_port]
...
             Setting the monitor port to 0 turns the monitoring function off, and au‐
             tossh will only restart ssh upon ssh's exit. For example, if you are using
             a recent version of OpenSSH, you may wish to explore using the
             ServerAliveInterval and ServerAliveCountMax options to have the SSH client
             exit if it finds itself no longer connected to the server. In many ways
             this may be a better solution than the monitoring port.
```

```shell
autossh -M 0 -R 6100:localhost:8789 服务器IP -o ServerAliveInterval=60
```

有些发行版比如Debian可以省略掉`-M 0`。

可以在服务器端查一下有没有额外的monitor port:

```shell
sudo lsof -i
```

## 后台静默运行

`-f`: 要求 ssh 在执行命令前退至后台。

`-N`: 不执行远程命令. 用于转发端口. (仅限协议第二版)。

所以可以：

```shell
autossh -M 0 -fNR 6100:localhost:8789 服务器IP -o ServerAliveInterval=60
```

```shell
ssh -fNR 6100:localhost:8789 服务器IP -o ServerAliveInterval=60
```

## 开机自启

可以用supervisor设置开机自启，配置文件：

```text
[program:ssh-intranet-penetration]
command=ssh -NR 6100:localhost:8789 服务器IP -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes
autostart=true
autorestart=true
stderr_logfile=/tmp/ssh-intranet-penetration_stderr.log
stdout_logfile=/tmp/ssh-intranet-penetration_stdout.log
user = searchstar
```

注意这里没有`-f`。这里用的是`ssh`而不是`autossh`，并且加上了`-o ExitOnForwardFailure=yes`，这样连接中断或者出现其他错误之后`supervisor`会自动重试。

## 客户端崩溃后重新连接

客户端崩溃后，重新连接时可能会出现这个错误：

```text
Warning: remote port forwarding failed for listen port 端口号
```

这时可以在服务器上查找监听这个端口的进程：

```shell
sudo lsof -i:端口号
```

这个进程是sshd fork出来的进程，杀掉它不影响其他端口的监听，而且可以把这个端口释放出来：

```shell
kill 进程号
```

然后再在客户端上重新构建反向隧道即可。

## 参考

[使用SSH反向隧道进行内网穿透——持续更新中](https://blog.csdn.net/jiangbenchu/article/details/84438959)

[利用AutoSSH建立SSH隧道，实现内网穿透](https://zhuanlan.zhihu.com/p/112227542)

<https://superuser.com/questions/1504220/ssh-tunnel-server-cant-close-listen-port-when-client-unexpected-close>
