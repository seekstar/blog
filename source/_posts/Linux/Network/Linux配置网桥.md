---
title: Linux配置网桥
date: 2022-04-18 14:09:52
tags:
---

## virsh default network

还有一种方式是利用virsh自带的default network，它是利用NAT实现的。

```shell
sudo virsh net-start default
```

然后`ip a`就可以看到一个名为`virbr0`的网桥。让它开机自启：

```shell
sudo virsh net-autostart default
```

```text
Network default marked as autostarted
```

```shell
sudo virsh net-list    
```

```text
 Name      State    Autostart   Persistent
--------------------------------------------
 default   active   yes         yes]
```

如果要允许普通用户在libvirt虚拟机里用这个网桥，首先确保`qemu-bridge-helper`有`setuid`，即权限位为`4755`，如果没有，则手动加上：

```shell
# 不同发行版的路径不一样
chmod u+s /usr/libexec/qemu-bridge-helper
chmod u+s /usr/lib/qemu/qemu-bridge-helper
```

然后在`/etc/qemu/bridge.conf`里加上`allow virbr0`。

参考：<https://forums.gentoo.org/viewtopic-t-1093206-start-0.html>

## nmcli (高危)

先安装`nmcli`，Debian 11:

```shell
sudo apt install network-manager
```

然后以root身份运行如下命令，记得把`ens3`换成自己的网卡号。

<!-- nmcli connection add type bridge ifname br0 stp no -->

```shell
nmcli connection add type bridge ifname br0
nmcli connection modify bridge-br0 bridge.stp no
nmcli connection add type bridge-slave ifname ens3 master bridge-br0
# 可能会改变IP。此时可能br0会得到一个IP，而原来的连接(ens3)在br0得到IP时会没有IP，过一段时间又可能会得到IP。由于IP改变，此时很可能会断网。
nmcli connection up bridge-slave-ens3
```

好像对无线网卡不起作用，`nmcli c up bridge-slave-wlan0`会报错：

```text
错误：连接激活失败：No suitable device found for this connection (device br0 not available because profile is not compatible with device (mismatching interface name)).
```

参考:

[CentOS8创建网桥](https://www.cnblogs.com/chia/p/13496248.html)

[如何在 Linux 里使用 nmcli 添加网桥 | Linux 中国](https://blog.csdn.net/F8qG7f9YD02Pe/article/details/79825476)

不起作用:

如果只有`nmcli connection up bridge-br0`，就算通过`nmcli connection down ens3`关掉原来的以太网连接，也会一直卡在获取IP地址。

<https://www.cyberciti.biz/faq/centos-8-add-network-bridge-br0-with-nmcli-command/#Adding_network_bridge>

<https://wiki.archlinux.org/title/Network_bridge>

<https://askubuntu.com/questions/574962/stuck-at-getting-ip-configuration>
