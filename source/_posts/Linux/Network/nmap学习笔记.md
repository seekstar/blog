---
title: nmap学习笔记
date: 2023-01-13 12:07:41
tags:
---

## 端口扫描

```shell
nmap -p- 地址
```

{% post_link Linux/Network/'linux查看开启的端口' %}

## 主机发现

通过ping的方式进行主机发现：

```shell
nmap -sn CIDR(Classless Inter-Domain Routing,无类别域间路由)
```

例如ping 192.168.1.1到192.168.1.255的所有IP：

```shell
nmap -sn 192.168.1.1/24
```

参考：<https://blog.csdn.net/weixin_61427044/article/details/127711345>
