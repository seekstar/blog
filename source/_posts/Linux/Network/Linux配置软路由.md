---
title: Linux配置软路由
date: 2024-09-03 09:41:41
tags:
---

假设出口网口是`end0`，入口网口是`end1`：

```shell
outdev=end0
indev=end1
# 子网不要与其他interface的IP重合
prefix=10.233.233
```

## 配置入口网口IP

```shell
#nmcli dev set $indev managed no
ip link set up dev $indev
ip addr add $prefix.1/24 dev $indev
```

但网线拔下来之后这个IP就会消失。可以参考下面的`开机自启`设置永久静态IP。

## 配置DHCP

```shell
apt install isc-dhcp-server

# 我们不需要IPv6的DHCP，因为IPv6有Router Advertisements
# https://tomsalmon.eu/2020/02/isc-dhcp-server-disable-dhcpv6-debian-9/
mv /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.$(date +%s%N)
echo INTERFACESv4=\"$indev\" > /etc/default/isc-dhcp-server

mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.$(date +%s%N)

cat > /etc/dhcp/dhcpd.conf <<EOF
option domain-name-servers 223.6.6.6;
option subnet-mask 255.255.255.0;
option routers $prefix.1;
subnet $prefix.0 netmask 255.255.255.0 {
  range $prefix.2 $prefix.254;
}

default-lease-time 600;
max-lease-time 7200;
EOF

systemctl restart isc-dhcp-server
```

`223.6.6.6`是阿里的DNS server。其他DNS server: <https://www.zhihu.com/question/32229915/answer/3572478879>

参考：<https://wiki.archlinux.org/title/Dhcpd>

## 开启转发

```shell
# 查看是否开启了转发
sysctl net.ipv4.ip_forward
# 开启转发
sysctl -w net.ipv4.ip_forward=1
```

## 配置NAT

```shell
iptables -t nat -A POSTROUTING -s $prefix.0/24 -o $outdev -j MASQUERADE
```

让防火墙不要拦截从indev到outdev的流量：

```shell
iptables -t filter -A FORWARD -i $indev -o $outdev -j ACCEPT
```

## IPv6 NAT

一般认为IPv6是不需要NAT的。但是在类似校园网的环境，每个接入的IPv6地址都需要进行认证，这时候就可以用IPv6 NAT，只需要一个通过认证的IP就可以代理整个子网的流量。

```shell
# 子网前缀
prefix6=fd00:1
```

```shell
# 生成link local address，这样链路才能工作
sysctl -w net.ipv6.conf.$indev.addr_gen_mode=0

# 设置静态IP
ip -6 addr add $prefix6::1/64 dev $indev

# 开启IPv6转发
sysctl -w net.ipv6.conf.all.forwarding=1
# 接受router advertisements
sysctl -w net.ipv6.conf.$indev.accept_ra=2

ip6tables -t nat -A POSTROUTING -o $outdev -j MASQUERADE
ip6tables -t filter -A FORWARD -i $indev -o $outdev -j ACCEPT
```

## 开机自启

```shell
cat >> /etc/network/interfaces <<EOF
allow-hotplug $indev
iface $indev inet static
	address $prefix.1
	netmask 255.255.255.0
iface end1 inet6 static
	address $prefix6::1
	netmask 64
EOF

sudo systemctl restart networking

systemctl enable isc-dhcp-server

cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_forward=1
net.ipv6.conf.$indev.addr_gen_mode=0
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.$indev.accept_ra=2
EOF
sysctl -p

sudo apt install -y iptables-persistent
# https://serverfault.com/a/714348
# :<NAME> <DEFAULT_POLICY> [<PACKET_COUNT>:<BYTE_COUNT>]
# PACKET_COUNT和BYTE_COUNT不重要，这里全部设置为0
cat > /etc/iptables/rules.v4 <<EOF
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.233.233.0/24 -o end0 -j MASQUERADE
COMMIT

*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A FORWARD -i end1 -o end0 -j ACCEPT
COMMIT
EOF

cat > /etc/iptables/rules.v6 <<EOF
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A FORWARD -i end1 -o end0 -j ACCEPT
COMMIT

*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -o end0 -j MASQUERADE
COMMIT
EOF
```
