---
title: ssh断点续传
date: 2022-09-17 22:13:11
tags:
---

可以用`rsync`。例子：

```shell
# 相当于scp sshname:/path/to/file .
rsync -zP -e ssh sshname:/path/to/file .
# 类似于scp -r sshname:/path/to/dir .
# 但是当/path/to/dir已经存在时不会在下面新建一个文件夹，而是直接把文件夹内容拷贝到/path/to/dir里面。
rsync -zPrt -e ssh sshname:/path/to/dir .
```

常用选项：

-v: verbose

-z: --compress。

-P: `-partial -progress`，部分传送和显示进度。

--bwlimit: 限速。用法：`--bwlimit=RATE`。单位默认`KiB/s`。也可以指定单位，比如`m`表示单位是`MiB/s`，`--bwlimit=1.5m`就表示限速到`1.5MiB/s`。

```text
--archive, -a            archive mode is -rlptgoD (no -A,-X,-U,-N,-H)
--recursive, -r          recurse into directories
--links, -l              copy symlinks as symlinks
--perms, -p              preserve permissions
--times, -t              preserve modification times
--group, -g              preserve group
--owner, -o              preserve owner (super-user only)
-D                       same as --devices --specials
--devices                preserve device files (super-user only)
--specials               preserve special files
```

--include, --exclude: <https://stackoverflow.com/questions/1228466/how-to-filter-files-when-using-scp-to-copy-dir-recursively>

参考：

<https://www.tecmint.com/rsync-local-remote-file-synchronization-commands/>

<https://blog.csdn.net/hepeng597/article/details/8960885>
