---
title: 使用netns绕过wireguard
date: 2023-03-27 19:54:53
tags:
---

最近需要使用cloudflare warp获得原生IP来访问ChatGPT和New Bing[^1]。使用[Cloudflare WARP 一键安装脚本 使用教程](https://p3terx.com/archives/cloudflare-warp-configuration-script.html)部署了之后发现套了一层cloudflare warp之后延迟上来了，带宽也被限制在了50Mbps左右。因此想要在同一个VPS上配置另一套代理，使其绕过cloudflare warp，直接访问互联网。由于上述一键部署脚本借助wireguard使用cloudflare warp，因此本教程介绍如何使用netns绕过wireguard。

## WireGuard

WireGuard是一种VPN技术[^2]。上述[一键脚本](https://p3terx.com/archives/cloudflare-warp-configuration-script.html)使用[wgcf](https://github.com/ViRb3/wgcf)生成wireguard的配置文件，进而生成一个叫做`wgcf`的device，这个就是VPN的device。流向`wgcf` device的流量会通过wireguard协议流向cloudflare warp，然后从cloudflare warp提供的原生IP流向目标IP。

传统VPN是通过路由表实现访问内网资源的，即在路由表中加入条目，将目标IP是目标内网的流量的出口设置为VPN的device。但是wireguard的目标是使得机器上所有的流量的出口都为它的device。因此wireguard官方的wg-quick工具在配置wireguard的时候，会加入这样一条路由设置[^3]：

```shell
ip -4 route add 0.0.0.0/0 dev wgcf table 51820
```

它新建了一个路由表`51820`，它将`0.0.0.0/0`也就是任何IP的出口device都设置成了wireguard设备（这里是`wgcf`）。注意`ip route show`看到的是`main` table，而这里的table 51820必须用`ip route show table 51820`才能看到，其内容为`default dev wgcf scope link`。按照我的理解，路由表要靠`ip rule`来调用。wg-quick添加了如下rule来调用刚刚定义的table 51820[^3]：

```shell
ip -4 rule add not fwmark 51820 table 51820
```

其含义为`fwmark`不为51820的流量使用table 51820来路由。这条rule可以使用`ip rule list`查看：

```text
0:	from all lookup local
18:	from <我的本地IP> lookup main
32764:	from all lookup main suppress_prefixlength 0
32765:	not from all fwmark 0xca6c lookup 51820
32766:	from all lookup main
32767:	from all lookup default
```

其中`32765:	not from all fwmark 0xca6c lookup 51820`就是刚刚加入的rule。可以看到fwmark不为`0xca6c`即51820的流量才会查询`main`和`default`路由表。因此我们绕过wireguard的思路就很明显了：把目标进程产生的流量的fwmark都设置成`51820`。

## network namespace (netns)

### 思路

使用netns构建一个NAT网络，然后使用iptables将来自NAT网络的所有流量的`fwmark`都设置成`51820`。

### 安装依赖

```shell
# Debian 11
sudo apt install iptables
```

### 查找真实网卡

首先通过`ip a`等方式找到机器的真实网卡，将其保存到`realdev`环境变量中：`realdev=eth0`

### 打开ip forward

```shell
# 查看是否已经打开
sudo sysctl net.ipv4.ip_forward
# 打开
sudo sysctl -w net.ipv4.ip_forward=1
```

### 创建netns

将它的名字存入`$spacename`，以后需要绕过wireguard的进程就在这个netns里运行：

```shell
# spacename不要含有数字，因为veth的两个端口的名字似乎只有末尾可以有数字。
spacename=全局唯一的名字
sudo ip netns add $spacename
```

查看所有netns: `ip netns`

删除netns: `ip netns del $spacename`

netns里的回环设备默认是关掉的，这样`ping localhost`会ping不通。为了避免以后发生奇怪的问题，我们将回环设备打开：

```shell
sudo ip netns exec $spacename ip link set lo up
```

### 创建veth连接

veth相当于一根虚拟的以太网线。将两端的名字分别设置为`${spacename}veth1`和`${spacename}veth2`：

```shell
sudo ip link add ${spacename}veth1 type veth peer name ${spacename}veth2
```

### 将一端放入netns里

这里将`${spacename}veth2`放入netns里：

```shell
sudo ip link set ${spacename}veth2 netns $spacename
```

`${spacename}veth1`作为与物理网卡交互的端口，保留在宿主机中。

### 为veth的两端设置IP并启用

这里将`${spacename}veth1`的IP设置为`192.168.45.2`，将netns里的`${spacename}veth2`的IP设置成`192.168.45.3`。它们的IP是可以换的，但要保证全局唯一。

```shell
sudo ifconfig ${spacename}veth1 192.168.45.2 netmask 255.255.255.0 up
sudo ip netns exec $spacename ifconfig ${spacename}veth2 192.168.45.3 netmask 255.255.255.0 up
```

现在`${spacename}veth1`和`${spacename}veth2`已经连通了，可以相互ping通。

### 在netns里设置路由

将`${spacename}veth1`设置成默认网关：

```shell
sudo ip netns exec $spacename route add default gw 192.168.45.2
```

这样netns里的流量都会从`${spacename}veth1`出来。

### 配置NAT

我们的netns的子网是`192.168.45.0/24`。我们将来自这个子网的流量的源IP都变成物理网卡的IP，这样物理网卡就相当于一个路由器，子网就相当于局域网了。

```shell
sudo iptables -t nat -A POSTROUTING -s 192.168.45.0/24 -o $realdev -j MASQUERADE
```

根据这篇博客：[使用 NAT 将 Linux network namespace 连接外网](http://www.cnblogs.com/sammyliu/p/5760125.html)，还需要做如下路由设置，以确保netns子网和物理网卡之间的流量不会被拦截：

```shell
sudo iptables -t filter -A FORWARD -i $realdev -o ${spacename}veth1 -j ACCEPT
sudo iptables -t filter -A FORWARD -o $realdev -i ${spacename}veth1 -j ACCEPT
```

然后将来自该NAT网络的所有流量的fwmark都设置成51820[^4]：

```shell
sudo iptables -t mangle -A PREROUTING -s 192.168.45.0/24 -j MARK --set-mark 51820
```

这样来自netns的所有流量都是直接流向物理网卡，不会经过wireguard了。

## 在netns中执行命令

格式：

```shell
ip netns exec $spacename 命令 参数1 参数2 ...
```

比如可以在netns里开一个shell: `ip netns exec $spacename bash`

在netns里ping：`ip netns exec $spacename ping google.com`

我们可以对比一下netns里`curl ip.gs`和在宿主机直接`curl ip.gs`打印出来的IP，看看我们是否成功绕过了wireguard: `ip netns exec $spacename curl ip.gs`

## IPv6

如果没有配置IPv6的话，socks代理可能会出问题。因此这里在netns中另外再配置一下ipv6，使得netns中可以访问公网中的ipv6地址。本节主要参考这篇博客：<https://blogs.igalia.com/dpino/2016/05/02/network-namespaces-ipv6/>

### 打开IPv6的forwarding

`accept_ra`的全称是accept router advertisement，它有三个级别[^5]：

```text
0: Do not accept Router Advertisements.
1: Accept Router Advertisements if forwarding is disabled.
2: Overrule forwarding behaviour. Accept Router Advertisements even if forwarding is enabled.
```

默认是1。此时直接打开IPv6的forwarding的话，如果default route是外界advertise进来的，就会导致default route消失：<https://serverfault.com/questions/976775/ipv6-default-route-is-removed-after-net-ipv6-conf-all-forwarding-is-set-to-1>

因此我们需要先将`accept_ra`设置为2，再打开IPv6的forwarding：

```shell
sysctl net.ipv6.conf.$realdev.accept_ra
# 2: Accept Router Advertisements even if forwarding is enabled.
sysctl -w net.ipv6.conf.$realdev.accept_ra=2

sysctl net.ipv6.conf.all.forwarding
sysctl -w net.ipv6.conf.all.forwarding=1
```

### 为veth的两端设置私有IPv6地址

`fd00::/8`是私有的IPv6地址块：<https://en.wikipedia.org/wiki/Private_network>。所以我们可以将`${spacename}veth1`的IP设置为`fd00::1/64`，将`${spacename}veth2`的IP设置为`fd00::2/64`：

```shell
ip -6 addr add fd00::1/64 dev ${spacename}veth1
ip link set dev ${spacename}veth1 up
ip netns exec $spacename ip -6 addr add fd00::2/64 dev ${spacename}veth2
ip netns exec $spacename ip link set dev ${spacename}veth2 up
```

### 在netns里设置IPv6路由

将`${spacename}veth1`设置成默认网关，让netns里的IPv6流量都通过`${spacename}veth2`发往`${spacename}veth1`：

```shell
ip netns exec $spacename ip -6 route add default dev ${spacename}veth2 via fd00::1
```

### 配置IPv6 NAT

```shell
ip6tables -t nat -A POSTROUTING -o $realdev -j MASQUERADE
```

显式accept netns和物理网卡之间的流量：

```shell
sudo ip6tables -t filter -A FORWARD -i $realdev -o ${spacename}veth1 -j ACCEPT
sudo ip6tables -t filter -A FORWARD -o $realdev -i ${spacename}veth1 -j ACCEPT
```

设置来自netns子网的流量的fwmark为51820，从而使得其bypass wireguard:

```shell
sudo ip6tables -t mangle -A PREROUTING -s fd00::/64 -j MARK --set-mark 51820
```

### 在netns中访问公网的IPv6地址

```shell
$ sudo ip netns exec $spacename ping ipv6.google.com
PING ipv6.google.com(nrt20s09-in-x0e.1e100.net (2404:6800:4004:80b::200e)) 56 data bytes
64 bytes from nrt20s09-in-x0e.1e100.net (2404:6800:4004:80b::200e): icmp_seq=1 ttl=105 time=2.37 ms
```

大功告成。

## 参考文献

[^1]: <https://github.com/haoel/haoel.github.io#94-cloudflare-warp-原生-ip>

[^2]: <https://en.wikipedia.org/wiki/WireGuard>

[^3]: <https://www.procustodibus.com/blog/2022/01/wg-quick-firewall-rules/#routes-and-policies>

[^4]: <https://ch1p.io/gentoo-wireguard-custom-resolver-captive-portal/>

[^5]: <https://sysctl-explorer.net/net/ipv6/accept_ra/>
