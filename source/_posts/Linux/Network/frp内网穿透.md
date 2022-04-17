---
title: frp内网穿透
date: 2021-12-30 21:56:06
tags:
---

frp有很详细的官方教程：<https://gofrp.org/docs/>

里面甚至有一些例子。最简单的例子：<https://gofrp.org/docs/examples/ssh/>

frp还支持p2p内网穿透，即服务器端只充当牵线搭桥的作用，当两个客户端通过服务器端建立p2p连接后，就没服务器端什么事了，不再消耗服务器端的流量。p2p的例子：<https://gofrp.org/docs/examples/xtcp/>

注意，如果服务器端设置了token的话，客户端的token要放到common下面。

可以用supervisor实现开机自启。

## CentOS

在CentOS 8 Stream上测试通过。这里以实现开启自启frps为例。

安装`supervisor`：

```shell
sudo yum install supervisor
```

默认是不激活的，还得手动激活supervisord服务：

```shell
sudo systemctl enable supervisord
sudo systemctl start supervisord
```

然后在`/etc/supervisord.d/frps.ini`里写入：

```
[program:frps] 
directory=frp安装目录绝对路径
command=frp安装目录绝对路径/frps -c frp安装目录绝对路径/frps.ini
autostart=true 
autorestart=true
stderr_logfile=/tmp/frps_stderr.log 
stdout_logfile=/tmp/frps_stdout.log 
user = 你的用户名
```

```shell
sudo supervisorctl update frps
sudo supervisorctl status frps
```

```
frps                             RUNNING   pid 33557, uptime 0:02:09
```

## debian系

在Deepin 20上测试通过。这里以实现开机自启frpc为例。

先安装`supervisor`:

```shell
sudo apt install supervisor
```

然后在`/etc/supervisor/conf.d/frpc.conf`里写入：

```
[program:frpc] 
directory=frp安装目录绝对路径
command=frp安装目录绝对路径/frpc -c frp安装目录绝对路径/frpc.ini
autostart=true 
autorestart=true
stderr_logfile=/tmp/frpc_stderr.log 
stdout_logfile=/tmp/frpc_stdout.log 
user = 你的用户名
```

然后

```shell
sudo supervisorctl update frpc
```

```
frpc: added process group
```

```shell
sudo supervisorctl status frpc
```

```
frpc                             RUNNING   pid 6214, uptime 5:17:13
```

更改了`/etc/supervisor/conf.d/frpc.conf`之后，这样重启：

```shell
sudo supervisorctl restart frpc
```

注意，如果当前的连接是通过frpc提供的内网穿透通道提供的，那么重启的过程中当前连接会断掉，然后这个shell就会被杀掉，然后这个重启过程会中断，然后连接就永远丢失了。为了使得重启的过程不会因为连接中断而终止，要用`nohup`使其与当前shell detach：

```shell
sudo -s
nohup supervisorctl restart frpc &
```

参考文献：[Supervisor使用详解](https://www.jianshu.com/p/0b9054b33db3)
