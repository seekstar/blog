---
title: Linux设置某目录下的默认权限
date: 2022-11-16 21:18:52
tags:
---

首先安装`setfacl`:

```shell
# Debian
sudo apt install acl
```

（可选）首先设置`setgid`，使得在这个目录下新建的文件和目录都继承这个目录的组：

```shell
chmod g+s <directory>
```

然后用`setfacl`设置这个目录下面新建文件或者目录时的默认权限。例如让这个目录下面新建的目录的group权限默认为`rwx`：

```shell
setfacl -d -m g::rwx <directory>
```

注意此时这个目录下面新建的文件的group权限默认为`rw`，没有可执行权限`x`。

如果要让这个目录下面所有的子目录，以及以后新建的目录都有这个默认权限，那么可以用`-R`选项：

```shell
setfacl -d -m g::rwx -R <directory>
```

来源：<https://unix.stackexchange.com/questions/1314/how-to-set-default-file-permissions-for-all-folders-files-in-a-directory>
