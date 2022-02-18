---
title: linux强制重启
date: 2021-01-15 17:24:03
---

一般情况下`reboot -nf`就够了。reboot的文档(`man reboot`)：

```
-n, --no-sync
       Don't sync hard disks/storage media before halt, power-off, reboot.
-f, --force
       Force immediate halt, power-off, or reboot. When specified once, this
       results in an immediate but clean shutdown by the system manager. When
       specified twice, this results in an immediate shutdown without
       contacting the system manager. See the description of --force in
       systemctl(1) for more details.
```

如果还不够，就`reboot -nff`。

如果还不够，就直接向内核发sysrq:

```shell
echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger
```

参考：<https://unix.stackexchange.com/questions/442932/reboot-is-not-working>
