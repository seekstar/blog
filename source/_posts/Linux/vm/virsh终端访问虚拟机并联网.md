---
title: virsh终端访问虚拟机并联网
date: 2021-08-08 05:18:41
---

如果要使用KVM的话，首先要让普通用户使用libvirt时能使用KVM：

{% post_link Linux/vm/'libvirt让普通用户能用kvm' %}

## 配置网桥

{% post_link Linux/Network/'Linux配置网桥' %}

## 将虚拟机导入virsh

这里假设domain的名字设置成centos8。先写一个`centos8.xml`，定义虚拟机的基本属性：

```xml
<domain type='kvm'>
  <name>centos8</name>
  <memory unit='GiB'>2</memory>
  <vcpu>4</vcpu>
  // 如果要让虚拟机可以迁移到其他宿主机上，要把这个删掉
  <cpu mode='host-passthrough' migratable='off'>
    <cache mode='passthrough'/>
  </cpu>
  <os>  
    <type arch='x86_64'>hvm</type>
  </os> 
  <devices>
    // 这里有的发行版是 /usr/bin/qemu-system-x86_64
    <emulator>/usr/libexec/qemu-kvm</emulator>
    <disk type='file' device='disk'>
      // 这里的type注意不要搞错了。可以用qemu-img info查看镜像的格式
      <driver name='qemu' type='qcow2'/>
      <source file='/home/searchstar/vm/centos.img'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    // 将宿主机上的/dev/sdb作为虚拟机的/dev/vdb。如果不需要可以删掉这部分。
    <disk type="block" device="disk">
      <driver name='qemu' type='raw' cache='none'/>
      <source dev='/dev/sdb'/>
      <target dev='vdb' bus='virtio'/>
    </disk>
    // 下面的是为了console访问
    <serial type='pty'>
      <source path='/dev/pts/0'/>
      <target type='isa-serial' port='0'>
        <model name='isa-serial'/>
      </target>
      <alias name='serial0'/>
    </serial>
    <console type='pty' tty='/dev/pts/0'>
      <source path='/dev/pts/0'/>
      <target type='serial' port='0'/>
      <alias name='serial0'/>
    </console>
    // 联网
    <interface type='bridge'>
      // 如果使用的是virsh default network，这里的br0要改成virbr0。
      <source bridge='br0'/>
      // 这行好像不用也可以？
      <model type='virtio'/>
    </interface>
  </devices>
</domain>
```

导入虚拟机：

```shell
virsh define centos8.xml
```

如果要删除虚拟机的话：

```shell
virsh undefine centos8
```

查看和编辑导入后的虚拟机配置：

```shell
virsh edit centos8
```

## 访问虚拟机

启动虚拟机：

```shell
virsh start centos8
```

强行关闭虚拟机：

```shell
virsh destroy centos8
```

终端访问虚拟机（要先start）：

```shell
virsh console centos8
// 退出按ctrl+]
```

如果没有反应，说明虚拟机里没有配置console，要看这篇文章进行配置：<https://blog.csdn.net/qq_41961459/article/details/119108333>

奇怪的是有时候console里shutdown之后不会自动destroy。这时要`ctrl+]`退出console，然后手动`virsh destroy`一下。

注意，普通用户的virsh域和root的virsh域是不互通的。

## 可选

### 通过复制镜像开新虚拟机

如果直接复制镜像来开新机器，会把machine ID一起复制到新机器，从而导致一些问题。更改machine ID的方法：{% post_link Linux/'Linux更改machine-ID' %}

此外，SSH host key也会复制过去，重新生成的方法：{% post_link Linux/'更改SSH-host-key' %}

参考：<https://octetz.com/docs/2020/2020-10-19-machine-images/>

### 配置静态IP

Deepin、Debian 11: {% post_link Linux/Network/'deepin设置静态IP' %}

如果发现仍然会获取动态IP，检查这几点：

- machine ID是唯一的，不然好像可能会从其他同machine ID的机器那里继承动态IP。

- dhcpcd服务没有运行。dhcpcd的全程是DHCP Client Daemon。

如果都没问题，再检查这里提到的另外几项：[Debian 9系统配置静态ip之后还会获取动态ip的问题](https://blog.csdn.net/weixin_44555609/article/details/109049543)

参考：[树莓派（Debian）系统设置了静态IP之后还会获取动态IP的问题解决（scope global secondary eth0）](https://www.cnblogs.com/EasonJim/p/8426642.html)

## 常见问题

### 无法自动联网

有的发行版没有设置开机自动联网，可以用`/sbin/dhclient`临时联网，开机自动联网需要手动设置：

[CentOS 7 怎样自动连接网络](https://blog.csdn.net/qq_40309341/article/details/121354132)

有时候也可能是因为网络设备的名字变了，导致原来的网络配置没有用了。Debian的话修改`/etc/network/interfaces`里的设备名即可，比如把`ens2`改成`enp0s2`。

### Could not open '/dev/sdb': Permission denied

将`/dev/sdb`的owner和group改成自己：

```shell
sudo chown $USER /dev/sdb
```

理论上把自己加入到disk组也可以，因为/dev/sdb的组是disk，但是我这里没用，不知道为什么。

### error: failed to connect to the hypervisor

```text
error: failed to connect to the hypervisor
error: Failed to connect socket to '/run/user/1000/libvirt/libvirt-sock': 没有那个文件或目录
```

解决方法：

```shell
sudo apt install libvirt-daemon
libvirtd -d
```

来源：<https://www.cnblogs.com/fang888/p/8496562.html>

### qemu-bridge-helper: failed to create tun device: Operation not permitted

<https://blog.csdn.net/qq_41961459/article/details/119520468>

### 错误：域管理的保存映像存在时拒绝取消定义

我进行如下操作之后就正常undefine了，原因不明。

```shell
virsh start centos8
virsh console centos8
virsh destroy centos8
virsh undefine centos8
```

## 参考文献

<https://libvirt.org/formatdomain.html>
[How to enable KVM virsh console access](https://ravada.readthedocs.io/en/latest/docs/config_console.html)
[利用virsh和xml文件创建虚拟机](https://blog.csdn.net/qq_15437629/article/details/77827033)
[kvm常见故障及解决方案](https://blog.51cto.com/dangzhiqiang/1783061)
[给KVM虚拟机增加硬盘](https://blog.csdn.net/chengxuyuanyonghu/article/details/42144079)
<https://www.linuxquestions.org/questions/linux-virtualization-and-cloud-90/qemu-kvm-permission-for-partition-disk-4175531592/>
[如何使KVM虚拟机的CPU和物理CPU一模一样？](https://blog.csdn.net/kepa520/article/details/49784433)
