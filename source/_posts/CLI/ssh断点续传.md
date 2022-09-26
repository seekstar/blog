---
title: ssh断点续传
date: 2022-09-17 22:13:11
tags:
---

可以用`rsync`。例子：

```shell
# 相当于scp sshname:/path/to/file .
rsync -zP -e ssh sshname:/path/to/file .
```

常用选项：

-v: verbose

-z: --compress。

-P: `-partial -progress`，部分传送和显示进度。

--bwlimit: 限速。用法：`--bwlimit=RATE`。单位默认`KiB/s`。也可以指定单位，比如`m`表示单位是`MiB/s`，`--bwlimit=1.5m`就表示限速到`1.5MiB/s`。

参考：

<https://www.tecmint.com/rsync-local-remote-file-synchronization-commands/>

<https://blog.csdn.net/hepeng597/article/details/8960885>
