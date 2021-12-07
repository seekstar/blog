---
title: CentOS 8创建TAP/TUN设备
date: 2021-07-26 14:57:45
---

CentOS 7还有nux-misc里的tunctl可以用，CentOS 8连那个都没有了。不过可以用```ip```

创建：

```shell
ip tuntap add tap0 mod tap
```

删除：
```shell
ip tuntap del tap0 mod tap
```

列出所有:
```shell
ip tuntap list
```

查看帮助：

```shell
ip tuntap help
```

参考文献：<https://www.mylinuxplace.com/create-taptun-device-centos-7/>
