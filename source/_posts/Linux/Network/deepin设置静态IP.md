---
title: deepin设置静态IP
date: 2021-08-14 19:00:46
---

`/etc/network/interfaces`里：

```text
# https://unix.stackexchange.com/a/128662/453838
allow-hotplug enp0s2
iface enp0s2 inet static
	address 10.249.44.127
	netmask 255.255.248.0
	gateway 10.249.40.1
	dns-nameserver 10.248.98.30
# https://askubuntu.com/questions/616856/how-do-i-add-an-additional-ipv6-address-to-etc-network-interfaces
iface end1 inet6 static
        address fd00:1::1
        netmask 64
```

网卡名字和当前子网掩码可以通过`ip addr`看。

当前网关可以通过`route -n`查看。

当前dns服务器的IP在`/etc/resolv.conf`里。

重启网络：

```shell
sudo systemctl restart networking
```

参考文献：
[Deepin设置静态IP](https://www.cnblogs.com/javayanglei/p/13305285.html)
[Linux查看DNS服务器及设置DNS服务器](https://jingyan.baidu.com/article/3c343ff7c289a30d37796312.html)
