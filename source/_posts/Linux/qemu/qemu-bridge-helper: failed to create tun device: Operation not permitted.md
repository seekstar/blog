---
title: "qemu-bridge-helper: failed to create tun device: Operation not permitted"
date: 2021-08-08 20:48:29
---

```shell
virsh start deepin
```

```
error: Failed to start domain deepin
error: internal error: /usr/lib/qemu/qemu-bridge-helper --use-vnet --br=br0 --fd=30: failed to communicate with bridge helper: 传输端点尚未连接
stderr=failed to create tun device: Operation not permitted
```

原因：```qemu-bridge-helper```需要set uid，但是deepin的apt没有自动设置这个权限。需要手动设置：

```shell
sudo chmod 4755 /usr/lib/qemu/qemu-bridge-helper
```

原文：<https://listman.redhat.com/archives/libvirt-users/2014-June/msg00094.html>
