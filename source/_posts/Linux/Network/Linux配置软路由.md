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

## 配置出口网口IP

```shell
#nmcli dev set $indev managed no
ip link set up dev $indev
ip addr add $prefix.1/24 dev $indev
```

## 配置DHCP

```shell
apt install isc-dhcp-server
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.$(date +%s%N)

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
