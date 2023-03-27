---
title: libvirt让普通用户能用kvm
date: 2022-04-17 20:31:48
tags:
---

有些发行版中，普通用户可能没法用KVM：

```shell
virsh capabilities | grep domain
```

```text
      <domain type='qemu'/>
      <domain type='qemu'/>
```

作为对比：

```shell
sudo virsh capabilities | grep domain
```

```text
      <domain type='qemu'/>
      <domain type='kvm'/>
      <domain type='qemu'/>
      <domain type='kvm'/>
```

所以应该是权限问题，`stat /dev/kvm`：

```text
Access: (0660/crw-rw----)  Uid: (    0/    root)   Gid: (  106/     kvm)
```

解决方案就是将用户添加进`kvm`（好像不用加入`libvirt`？）：

```shell
# sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
```

然后重新登录，运行`id`确认已经加入`kvm`组了，然后：

```shell
virsh capabilities | grep domain
```

```text
      <domain type='qemu'/>
      <domain type='kvm'/>
      <domain type='qemu'/>
      <domain type='kvm'/>
```

就正常了。

来源：<https://serverfault.com/questions/1002043/libvirt-has-no-kvm-capabilities-even-though-qemu-kvm-works>

ps: CentOS Stream 8默认配置下普通用户可使用KVM，不知道是不是因为`qemu`用户默认就在`kvm`组里。
