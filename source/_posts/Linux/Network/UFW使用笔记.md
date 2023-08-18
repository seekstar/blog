---
title: UFW使用笔记
date: 2023-03-19 14:53:15
tags:
---

## 安装

```shell
sudo apt install ufw
```

安装之后默认是inactive的状态。

## 查看防火墙状态

```shell
sudo ufw status
```

里面会给出防火墙是不是active的。如果是active的话，还会打印出已经设置了哪些规则。

如果是inactive的话，如果想要看已经添加的规则，可以`sudo ufw show added`。来源：<https://askubuntu.com/a/533664>

## Allow SSH

你需要先allow OpenSSH再enable，不然ssh会连不上。

如果SSH端口是22，可以这样：

```shell
sudo ufw allow OpenSSH
# 或者
sudo ufw allow ssh
```

如果不是，需要显式allow这个端口：

```shell
sudo ufw allow <端口>
```

## 激活与关闭防火墙

```shell
sudo ufw enable
sudo ufw disable
```

## 打开和关闭端口

```shell
sudo ufw allow <端口>
sudo ufw delete allow <端口>
```

## 允许从某IP连接到某端口

```shell
sudo ufw allow from <IP/CIDR> to any port <端口>
# 撤回
sudo ufw delete allow from <IP/CIDR> to any port <端口>
```

## 参考文献

<https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands>
