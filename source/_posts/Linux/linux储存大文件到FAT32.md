---
title: linux储存大文件到FAT32
date: 2020-02-20 21:16:38
---

FAT32的单个文件的最大大小为4G，超过4G的文件就必须要分割成几个小文件再拷贝进去。
linux下提供了split命令来分割文件。
```shell
split -db 2G original_file filename
```
d: 后缀用00,01,02……如果不使用这个选项，就是用aa、ab、ac……
b: 指定分块大小。这里指定为2G
filename: 指定要生成的文件的文件名，如果不指定，则默认为x

效果：把original_file分割成2G大小的filename01, filename02, filename03……

实测不能直接分割为4G，因为还是会提示超过4G大小不让复制。

合并
```shell
cat filename* > original_file
```

如果要在windows上把被分割的文件重新整合起来，可以下载git for windows
<https://git-scm.com/download/win>
安装后在文件管理器中右键会有Git Bash Here的选项。
点击之即可使用git bash，里面提供了一个简单的linux命令行环境，可以用它整合文件。
