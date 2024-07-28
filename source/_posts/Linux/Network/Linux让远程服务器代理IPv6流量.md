---
title: Linux让远程服务器代理IPv6流量
date: 2024-07-27 14:17:54
tags:
---

## 使用场景

本地机器只能访问IPv4网络。远程服务器能访问IPv4网络，也能访问IPv6网络。这篇博客介绍如何让远程服务器代理本地机器的IPv6流量，从而让本地机器也能访问IPv6网络。

## 主要思路

在远程服务器上创建一个netns，搭IPv6 NAT，这样netns里面就能通过IPv6 NAT访问公网。

然后在netns和本地机器分别建立一个tap，用SSH把两个tap连接起来，本地机器就能通过tap连接到netns。由于IPv6的路由是自动配置的，所以本地机器的tap会自动获得一个IPv6并且配置好路由，然后本地机器的IPv6流量就自动通过tap路由到netns里，然后通过netns的IPv6 NAT访问公网了。

## 创建netns

```shell
# spacename不能带数字，否则之后${spacename}veth1会创建失败。
spacename=纯字母的名字
sudo ip netns add $spacename
sudo ip netns exec $spacename ip link set lo up
```

可以开一个netns里的bash在netns里执行命令，方便调试：

```shell
sudo ip netns exec $spacename bash
```

## 连接宿主机和netns

创建一根虚拟以太网线，一头是`${spacename}veth1`，另一头是`${spacename}veth2`：

```shell
sudo ip link add ${spacename}veth1 type veth peer name ${spacename}veth2
```

将一头放入netns:

```shell
sudo ip link set ${spacename}veth2 netns $spacename
```

## Router Advertisement Daemon

我们在宿主机上配置好Router Advertisement Daemon之后，宿主机上的IPv6子网就可以通过router advertisement自动配置路由：<https://askubuntu.com/a/676543>

安装`radvd`：

```shell
# Debian 12
sudo apt install radvd
```

配置文件路径：`/etc/radvd.conf`。官方文档：<https://linux.die.net/man/5/radvd.conf>

我们这里这样配置就可以了：

```shell
sudo bash -c "echo \"interface ${spacename}veth1 {
	AdvSendAdvert on;
	prefix fd00::/64 {
		AdvOnLink on;
		AdvAutonomous on;
	};
};\" > /etc/radvd.conf"
```

然后启动daemon：

```shell
sudo systemctl start radvd
```

## 给veth配置静态IP

`fd`开头的地址是unique local address。我们把`veth1`的IPv6地址设置为`fd00::1`：

```shell
sudo ip link set dev ${spacename}veth1 up
sudo ip -6 addr add fd00::1/64 dev ${spacename}veth1
```

把`veth2`打开：

```shell
sudo ip netns exec $spacename ip link set dev ${spacename}veth2 up
```

等几秒钟，`radvd`会自动给`veth2`基于它的MAC地址配置IPv6地址并且配置路由。然后我们就可以在netns里ping通`fd00::1`了。

## 配置NAT

通过`ip a`查看宿主机用来连接到公网的接口，把名字放入`outdev`变量中。我的机器是`end0`：

```shell
outdev=end0
```

打开宿主机的IPv6转发功能：

```shell
sudo sysctl -w net.ipv6.conf.$outdev.accept_ra=2
sudo sysctl -w net.ipv6.conf.all.forwarding=1
```

然后我们配置NAT，将从`outdev`转发出去的流量的IP都换成`outdev`上的IP：

```shell
sudo ip6tables -t nat -A POSTROUTING -o $outdev -j MASQUERADE
```

让防火墙不要拦截从`veth1`到`outdev`的流量：

```shell
sudo ip6tables -t filter -A FORWARD -o $outdev -i ${spacename}veth1 -j ACCEPT
```

先确保`/etc/resolv.conf`里有IPv6的nameserver，没有的话在这里挑一个写进去：[纯ipv6的linux服务器网络配置方案](https://blog.csdn.net/yanhanhui1/article/details/117111455)

然后在netns里就可以正常访问IPv6公网了：

```shell
sudo ip netns exec $spacename curl -6 https://ip.gs
```

如果打印出来的地址是`outdev`的IPv6地址，说明IPv6 NAT配置成功了。

## 在netns里建立桥接

我们需要在netns里建立一个tap。netns里的tap需要桥接到veth上。为此我们需要先建立bridge，然后将`veth2`和tap分别桥接上去。

新建bridge，命名为`br0`：

```shell
sudo ip netns exec $spacename ip link add name br0 type bridge
```

将`veth2`桥接到`br0`上：

```shell
sudo ip netns exec $spacename ip link set ${spacename}veth2 master br0
```

启动`br0`：

```shell
sudo ip netns exec $spacename ip link set br0 up
```

给`br0`配置静态IP `fd00::2`：

```shell
sudo ip netns exec $spacename ip -6 addr add fd00::2/64 dev br0
```

以后`veth2`只用作`br0`和`veth1`之间的通信，所以我们删除`veth2`自动配置的IPv6地址：

```shell
sudo ip netns exec $spacename ip address flush dev ${spacename}veth2
```

并且删除IPv6路由表中veth2相关的项：

```shell
sudo ip netns exec $spacename ip -6 route flush dev seekstarveth2
```

检查一下现在netns里能不能访问IPv6公网：

```shell
sudo ip netns exec $spacename curl -6 https://ip.gs
```

## 连接本地机器和netns

首先，即使tap是通过桥接的方式连接到`veth2`，也必须要在netns里把IPv6的forwarding开起来：

```shell
sudo ip netns exec $spacename sysctl -w net.ipv6.conf.br0.accept_ra=2
sudo ip netns exec $spacename sysctl -w net.ipv6.conf.all.forwarding=1
```

不然最后本地机器转发到netns里的tap的流量似乎不会被转发给veth1。

然后在netns中创建一个tap，这里命名为`tap0`（也可修改成别的）：

```shell
sudo ip netns exec $spacename ip tuntap add dev tap0 mode tap
```

将tap连接到br0上：

```shell
sudo ip netns exec $spacename ip link set tap0 master br0
```

确认一下是不是连上去了：

```shell
sudo ip netns exec $spacename brctl show br0
```

```text
bridge name     bridge id               STP enabled     interfaces
br0             8000.162344e2cdc6       no              seekstarveth2
                                                        tap0
```

然后尽快在netns中将这个tap跟netns的localhost:6301连接起来，不然tap会从br0断开：

```shell
# 保持打开
# iff-up: immediately activate the interface
# tun-name=tap0: tap0可以换成别的名字
sudo ip netns exec $spacename socat TUN,tun-type=tap,tun-name=tap0,iff-up TCP6-LISTEN:6301,fork,reuseaddr
```

上面的命令会占用一个终端。接下来我们开一个新终端继续操作。

然后在宿主机上监听`6301`端口，并将流量转发给netns的6301端口：

```shell
# 保持打开
socat tcp-listen:6301,reuseaddr,fork tcp:[fd00::2]:6301
```

然后我们在本地机器上把远程服务器的6301端口映射到本地机器的6301端口：

```shell
# 保持打开
ssh -NL 6301:localhost:6301 远程服务器
```

最后，在本地机器创建一个tap，并将它跟6301端口连接起来：

```shell
# https://gist.github.com/cfra/752d6e761225fd5bf783b44abe30f707
# 保持打开
sudo socat TUN,tun-type=tap,iff-up TCP:localhost:6301
```

然后等几秒钟，本地机器的tap会收到route advertisement然后自动配置IP和路由。接着我们就可以在本地机器访问IPv6了：

```shell
curl -6 https://ip.gs
```

可以看到输出的是远程服务器`outdev`的IPv6地址。

相关：<https://superuser.com/questions/879498/make-socat-listen-on-both-ipv4-and-ipv6-stacks>

## 撤销所有更改

```shell
sudo ip link delete ${spacename}veth1
sudo ip netns exec $spacename ip link delete tap0
sudo ip netns exec $spacename ip link delete br0
sudo ip netns delete $spacename
```

## 注意事项

一个tap似乎只能用于一台机器，共用tap的话连接会非常不稳定。因此如果有多台机器都需要让远程服务器代理IPv6流量，只能在远程服务器创建多个tap，然后让这些机器分别连接到一个tap上。
