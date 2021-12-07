---
title: Linux创建只读目录链接
date: 2021-07-01 16:55:49
---

相当于让一个可写的目录软链接到另一个地方变成只读的目录，但是原目录仍然保持可写。解决方法是用```mount --bind```，将目录挂载到目标点，变成只读文件系统。

```shell
mount --bind -r /path/to/source/ /path/to/dest/
```
```shell
umount /path/to/dest/
```

原文：<https://askubuntu.com/questions/243380/how-to-create-a-read-only-link-to-a-directory>
