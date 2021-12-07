---
title: "qemu-system-x86_64: warning: host doesn‘t support requested feature: CPUID.80000001H:ECX.svm [bit 2]"
date: 2021-08-08 03:14:47
---

我在virtualbox里的虚拟机里用qemu创建虚拟机时报这个错。解决方法是在命令里加上```-cpu host```

```shell
sudo qemu-system-x86_64 -cpu host -m 1024 -enable-kvm centos.img -cdrom ~/Downloads/CentOS-8.2.2004-x86_64-minimal.iso
```

不过仍然不会用上kvm的样子。

参考：<https://github.com/GNS3/gns3-server/issues/1639>
