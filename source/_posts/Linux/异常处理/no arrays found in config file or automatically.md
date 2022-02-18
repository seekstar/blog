---
title: no arrays found in config file or automatically
date: 2021-06-02 13:13:47
---

原因是安装其他操作系统时共用了swap分区，导致uuid变化了。

先修改`/etc/fstab`，把swap分区那行给注释掉，这样错误的uuid就被删掉了：
```
# /dev/nvme0n1p3
#UUID=2589c54c-1093-43b4-820e-5fa3f7e2d600      none            swap            defaults,pri=-2 0 0
```

然后重新生成mdadm.conf：
```shell
sudo rm /etc/mdadm/mdadm.conf
sudo update-initramfs  -u
```
这个时候系统（可能）会自动找到swap分区。

然后重启就很快了，不会出现这种错误了。

如果系统没有自动找到新的swap分区的话，试试手动指定新的uuid：<https://blog.csdn.net/KuXiaoQuShiHuai/article/details/99686620>
