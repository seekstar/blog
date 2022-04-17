---
title: nmcli device status unmanaged
date: 2022-04-17 21:12:18
tags:
---

症状：

```shell
nmcli device status
```

```text
DEVICE        TYPE      STATE                                  CONNECTION
enp89s0       ethernet  unmanaged                              --         
lo            loopback  unmanaged                              --
```

检查`/etc/NetworkManager/NetworkManager.conf`，如果`[ifupdown]`里的`managed`是`false`，那就改成`true`：

```text
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=true
```

然后重启服务：

```shell
sudo systemctl restart NetworkManager
```

然后就好了：

```shell
nmcli device status
```

```text
DEVICE        TYPE      STATE                                  CONNECTION 
enp89s0       ethernet  connected (externally)                 enp89s0
lo            loopback  unmanaged                              --
```

参考：

<https://askubuntu.com/questions/1115117/ubuntu-18-04-ethernet-not-managed>

相关：

<https://askubuntu.com/questions/882806/ethernet-device-not-managed>

<https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-configuring_ip_networking_with_nmcli>
