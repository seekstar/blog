---
title: grub-installer fatal error
date: 2021-02-04 11:57:32
---

我把EFI分区的类型从逻辑分区改成主分区就好了。
好像除了EFI分区，所有分区都可以是逻辑分区，包括挂载到```/```的分区。
