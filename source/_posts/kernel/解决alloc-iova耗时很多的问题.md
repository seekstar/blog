---
title: 解决alloc_iova耗时很多的问题
date: 2026-03-04 17:24:02
tags:
---

在Debian12上跑实验，在perf火焰图上发现`alloc_iova`消耗了很多CPU时间。GPT说是因为IOVA碎片化了。

我发现升级到Debian13之后好像就没这个问题了。可能是因为Debian13的新内核缓解了IOVA碎片化的问题。

另一种方法是把IOMMU模式改成passthrough：在`/etc/default/grub`里的`GRUB_CMDLINE_LINUX_DEFAULT`里加上`intel_iommu=on iommu=pt`，然后`sudo update-grub`，然后重启。然后`sudo dmesg | grep iommu:`就可以看到`Default domain type`是Passthrough。这会降低安全性。在保证驱动和设备都是可信的情况下才能用这个。
