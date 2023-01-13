---
title: nmap学习笔记
date: 2023-01-13 12:07:41
tags:
---

## 端口扫描

```shell
nmap -p端口 地址
```

### 地址

地址可以用通配符，比如`192.168.*.1`表示`192.168.1.1`、`192.168.2.1`、……、`192.168.255.1`。

也可以用CIDR（Classless Inter-Domain Routing，无类别域间路由），比如`192.168.1.1/24`表示`192.168.1.1`到`192.168.1.255`的所有地址。

### 特定端口

扫描22号端口：

```shell
nmap -p22 地址
```

### 范围

扫描`22`到`25`号端口：

```shell
nmap -p22-25 地址
```

### 所有端口

`-`表示所有端口（1到65535）。

```shell
nmap -p- 地址
```

{% post_link Linux/Network/'linux查看开启的端口' %}

### 只报告open的端口

`--open: Only show open (or possibly open) ports`

参考：[nmap超快高效扫描端口](https://blog.csdn.net/cookieXSS/article/details/105475535)

## 主机发现

通过ping的方式进行主机发现：

```shell
# -sn: Ping Scan - disable port scan
nmap -sn 地址
```

例如ping 192.168.1.1到192.168.1.255的所有IP：

```shell
nmap -sn 192.168.1.1/24
```

参考：

[Nmap发现局域网中存活主机](https://blog.csdn.net/weixin_61427044/article/details/127711345)
