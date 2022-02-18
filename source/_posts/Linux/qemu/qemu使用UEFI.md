---
title: qemu使用UEFI
date: 2022-01-09 01:35:51
tags:
---

加上`--boot uefi`参数即可。检验：

```shell
ls /sys/firmware/efi/efivars
```

输出一堆东西就说明是UEFI模式。

参考：

<https://fedoraproject.org/wiki/Using_UEFI_with_QEMU>

<https://archlinuxstudio.github.io/ArchLinuxTutorial/#/rookie/basic_install>
