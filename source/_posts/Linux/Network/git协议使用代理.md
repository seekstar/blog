---
title: git协议使用代理
date: 2022-05-27 21:46:24
tags:
---

首先，`github.com`的`git@github.com:xxx/xxxx.git`使用的其实不是git协议，而是SSH协议，所以如果要代理之，需要配置的其实是SSH代理，在`~/.ssh/config`里配置如下：

```text
Host github.com
        User git
        # ProxyCommand netcat -X 5 -x <socks_host>:<socks_port> %h %p
        ProxyCommand netcat -x <socks_host>:<socks_port> %h %p
```

其中`%h`表示host，`%p`表示port。

注意这里的`netcat`有些教程里是写的`nc`，但是这是不合适的，因为`nc`在debian系中指向`ncat`，而在CentOS中指向`netcat`，两者是不同的。

而`netcat`其实也有很多个变种。在Debian系和CentOS中默认是OpenBSD netcat，而在Arch Linux中好像默认是GNU Netcat。这里使用的是OpenBSD netcat，在Arch Linux中可以通过安装`openbsd-netcat`来从默认的GNU Netcat切换到OpenBSD netcat。参考：<https://wiki.archlinux.org/title/Network_tools#Netcat>

`man netcat`:

```text
NAME
     nc — arbitrary TCP and UDP connections and listens

SYNOPSIS
     nc [-46bCDdFhklNnrStUuvZz] [-I length] [-i interval] [-M ttl] [-m minttl]
        [-O length] [-P proxy_username] [-p source_port] [-q seconds] [-s source]
        [-T keyword] [-V rtable] [-W recvlimit] [-w timeout] [-X proxy_protocol]
        [-x proxy_address[:port]] [destination] [port]

-X proxy_protocol
        Use proxy_protocol when talking to the proxy server.  Supported protocols
        are 4 (SOCKS v.4), 5 (SOCKS v.5) and connect (HTTPS proxy).  If the proto‐
        col is not specified, SOCKS version 5 is used.

-x proxy_address[:port]
        Connect to destination using a proxy at proxy_address and port.  If port
        is not specified, the well-known port for the proxy protocol is used (1080
        for SOCKS, 3128 for HTTPS).  An IPv6 address can be specified unambigu‐
        ously by enclosing proxy_address in square brackets.  A proxy cannot be
        used with any of the options -lsuU.
```

如果真的是使用的git协议，那么参考：<https://yechengfu.com/blog/2015/01/16/use-git-behind-proxy/>
