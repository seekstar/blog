---
title: Linux更改machine ID
date: 2022-05-11 18:50:41
tags:
---

用`systemd-machine-id-setup`可以重新生成machine ID。

如果DBUS machine ID存在的话，会直接将其拷贝过来，所以可以先更新DBUS machine ID：

```shell
sudo bash -c "dbus-uuidgen > /var/lib/dbus/machine-id"
sudo rm /etc/machine-id
sudo systemd-machine-id-setup
```

```text
Initializing machine ID from D-Bus machine ID.
```

参考: <https://www.linuxquestions.org/questions/slackware-14/security-implications-of-var-lib-dbus-machine-id-thoughts-4175665203/>

也可以把`/var/lib/dbus/machine-id`和`/etc/machine-id`一起删除，再用`systemd-machine-id-setup`重新生成`/etc/machine-id`，然后再创建一个符号链接：

```shell
sudo rm /var/lib/dbus/machine-id /etc/machine-id
sudo systemd-machine-id-setup
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id
```

ArchLinux的`/var/lib/dbus/machine-id`默认就是一个指向`/etc/machine-id`的符号链接。

参考：

[Linux7重新生成Machine-ID](https://blog.csdn.net/u010674953/article/details/117692068)

<https://wiki.debian.org/MachineId>
