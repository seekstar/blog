---
title: SPDK回收hugemem
date: 2022-02-13 16:56:55
tags:
---

SPDK分配了HUGEMEM之后，如果程序申请了huge page然后崩溃了，这些huge page就相当于内存泄漏了，仍然保持被分配的状态。要回收这些huge page，在spdk的目录下执行

```shell
sudo ./scripts/setup.sh reset
```

即可。reset的帮助信息：

```text
reset             Rebind PCI devices back to their original drivers.
                  Also cleanup any leftover spdk files/resources.
                  Hugepage memory size will remain unchanged.
```

但是这个方法貌似对SpanDB不起作用？
