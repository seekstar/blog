---
title: linux解压文件和创建压缩文件
date: 2019-05-29 18:45:49
tags:
---

约定：
FileName表示文件名，不能是目录名
name表示可以是文件名，也可以是目录名。
DirName表示目录名。

温馨提示：
可以用vim预览压缩包里的东西，例如

```shell
vim FileName.tar.xz
```

防止解压出一堆散的文件污染目标文件夹。

## 速记

对于`.tar.*`的格式，tar的类别参数如下：

| 格式 | 参数 |
| ---- | ---- |
| `.tar.gz` | `z` |
| `.tar.xz` | `J` |
| `.tar.bz2` | `j` |

## .rar

~~参考网站中的.rar部分好像有误~~
先安装rar软件：

```shell
sudo apt install rar
```

### 解压

- 解压到当前目录：

```shell
rar e FileName.rar
```

e: extract的e

- 解压到指定目录：

```shell
rar x FileName.rar DirName/
```

x: extract的x
DirName后面一定要加“/”，例如~/lalala/

### 创建

```shell
rar a FileName.rar DirName
```

DirName后加不加“/”都行
如果要指定目标文件路径，可以在FileName指定。如~/backup/sth.rar

## .zip

~~参考网站中的.zip部分好像有误~~

### 解压

- 解压到当前目录：

```shell
unzip FileName.zip
```

- 解压到指定目录：

```shell
unzip FileName.zip -d DirName
```

### 创建

```shell
zip FileName.zip -r DirName
```

如果有符号链接的话，`zip`会顺着符号链接把它指向的东西打包进来。如果想要把符号链接本身打包进来，需要加上`--symlinks`。

## .tar

参考网站：http://www.linuxdiyf.com/view_154669.html

```text
       -h, --dereference
              Follow symlinks; archive and dump the files they point to.
```

### 解压到当前目录

```shell
tar -xvf FileName.tar
```

x: 解压文件(extract里的x)
v: 打印详细信息(verbose)
f: 指定文件名(file)

### 解压到指定目录

```shell
tar -xvf FileName.tar -C DirName
```

C: 解压到制定目录
凡是用tar命令解压，都可以使用这个选项来指定输出路径，如tar.gz和tar.xz。

### 创建

```shell
tar -cvf FileName.tar files
```

其中files可以是文件夹名，也可以是表示文件的正则表达式（如*.jpg）
c: 压缩(compress)

尤其要注意，tar加入文件时会把文件的相对位置也加进去，解压出来的文件都根据它们的相对位置放到解压到的目录。因此进行压缩时要cd到要压缩的文件或文件夹所在目录。

也可以用`-C`选项让tar先cd到对应目录再将文件打包。例如要将`dir1`和`dir2`下面的所有文件和目录都打包在一起（不打包`dir1`和`dir2`本身），可以这样：

```shell
tar -cvf name.tar -C dir1 . -C ../dir2 .
```

`-C dir1`表示先cd到`dir1`，`.`表示把当前目录下所有文件都打包，然后`-C ../dir2`表示再`cd ../dir2`，然后`.`表示把当前目录下所有文件都打包。

来源：<https://unix.stackexchange.com/questions/703696/creating-a-tar-gz-archive-of-multiple-directories-of-different-locations-tar>

## .gz

参考网站：https://blog.csdn.net/zdx1515888659/article/details/82841100

### 单线程解压

```shell
# 到当前目录
gzip -d FileName.gz
```

d: 解压(decompress)
会自动把原来的FileName.gz删除并生成解压后的文件。

可加上选项k保留原文件。

```shell
gzip -dk FileName.gz
```

k: keep

### 单线程压缩

```shell
# 到当前目录
gzip FileName
```

会自动把原文件删掉并创建FileName.gz。
gzip的常用选项：
k: 保留源文件(keep)

- gzip其他常用选项
v: 打印详细信息(verbose)

### 多线程解压

`gzip`不支持多线程解压。一般来讲`gzip`的解压非常快，通常可以达到I/O设备的吞吐极限，所以一般也没必要多线程解压。

`unpigz`通过流水线的方式将解压并行化了，但是并行度有限。

```shell
# 到当前目录
unpigz xxx.gz
```

默认使用所有核。可以加上`-p 线程数`限制使用的核数。

默认解压完成后删除原文件。加上`-k`可以保留原文件。

### 多线程压缩

`gzip`单线程压缩很慢，而且不支持多线程压缩。用`pigz`可以实现多线程压缩。

```shell
# 到当前目录
pigz 文件名
```

实测压缩大文件可以跑满CPU，而且不影响压缩率。

默认使用所有核。可以加上`-p 线程数`限制使用的核数。

默认解压完成后删除原文件。加上`-k`可以保留原文件。

## .tar.gz

参考网站：https://blog.csdn.net/weixin_42628856/article/details/81332138
https://zhidao.baidu.com/question/9844116.html

顾名思义，.tar.gz就是对tar文件用gzip压缩得到的文件。所以解压可以先解压gz，再解压tar，压缩也可以先压缩成tar，再压缩成gz。

也可以使用一条命令完成解压或压缩。

### 单线程解压

- 解压到当前目录

```shell
tar -zxvf FileName.tar.gz
```

z表示gz

- 解压到指定目录

```shell
tar -zxvf FileName.tar.gz -C path
```

### 单线程压缩

```shell
tar -zcvf FileName.tar.gz files
```

其中files可以是文件夹名，也可以是表示文件的正则表达式（如*.jpg）

### 多线程压缩

```shell
# tar
#   -c: create
#   -f: archive file. 这里是“-”， 表示输出到stdout
# pigz
#   -: 文件名是"-"，表示从stdin读取，并且输出到stdout
tar -cf - 文件或目录 | pigz - > FileName.tar.gz
```

## .xz

xz格式压缩率极高，但是压缩和解压也极慢。

### 单线程解压

- 解压到当前目录

```shell
xz -d FileName.xz
```

会自动把源文件删除，然后生成文件FileName。可以用选项k保存源文件

```shell
xz -dk FileName.xz
```

k: keep

- 解压为指定文件名

```shell
xz -dc FileName.xz > FileName2
```

c: 把压缩文件输出到stdout。不删除源文件

### 单线程压缩

- 压缩到当前目录

```shell
xz -z FileName
```

会自动把原文件删掉，然后生成FileName.xz。可以用选项k保存原文件

```shell
xz -zk FileName
```

### 多线程压缩

```shell
xz -zkT0 FileName
```

T: 使用多线程，后面跟线程数。如果参数是0，则表示使用[机器核心数]个线程。

这种方法只能压缩文件。多线程压缩目录的方法见.tar.xz

## .tar.xz

参考网站：
https://blog.csdn.net/wangshan3366/article/details/83095643
https://zhidao.baidu.com/question/1639604825027635340.html

顾名思义，就是把文件先打包成tar，再压缩成xz。
解压时可以先解压xz得到tar文件，再解压tar。

也可以使用一条命令完成解压或压缩。

### 单线程解压

```shell
tar xJf name.tar.xz
```

x: extract
J: xz

### 单线程压缩

```shell
tar cJf name.tar.xz name
```

c: compress

### 多线程解压

```shell
xz -dcT0 FileName.tar.xz | tar -xC DirName
```

tar不带f选项，表示从stdin中读取。

### 多线程压缩

这种方法可以压缩文件，也可以压缩目录

```shell
tar -cf - name | xz -T0 -c > FileName.tar.xz
```

知识点：
tar如果输出的文件名是“-”，则会输出到stdout
如果xz没有指定源文件则会从stdin中读取

## bzip2

压缩解压过程都会把源文件删掉。如果要保留，选项里加个`k`就好了（keep)。

### 多线程

用pbzip2。如果不指定线程数，就自动检测能用多少个线程。

解压：

```shell
pbzip2 -dp线程数 FileName.bz2
```

生成的文件是FileName，会自动把FileName.bz2删掉。

压缩：

```shell
pbzip2 -zp线程数 FileName
```

生成的文件是FileName.bz2。
其他压缩选项：
`--fast`: 牺牲压缩率，提高压缩和解压速度。
`--best`（默认）: 牺牲压缩速度，提高压缩率。

## tar.bz2

### 单线程压缩

```shell
tar -cjf name.tar.bz2 name
```

### 单线程解压

```shell
tar xjf name.tar.bz2
```

### 多线程解压

```shell
pbzip2 -cdp线程数 b.tar.bz2 | tar -xC DirName
```

## zstd

通用选项：

```text
       •   --no-progress: do not display the progress bar, but keep all other messages.
```

### 解压

解压为当前文件夹下的`FileName`：

```shell
unzstd FileName.zst
```

输出到stdout:

```shell
unzstd FileName.zst --stdout
```

也可以解压多个文件：

```shell
unzstd FileName1.zst FileName2.zst
```

会解压为`FileName1`和`FileName2`。

到指定目录：

```shell
unzstd FileName.zst -o path/file
```

### 压缩

压缩为`path/FileName.zst`：

```shell
zstd path/FileName
# 多线程
zstdmt path/FileName
```

也可以压缩多个文件：

```shell
zstdmt path/FileName1 path/FileName2
```

会压缩为`path/FileName1.zst`和`path/FileName2.zst`。

## 参考文献

<https://www.cnblogs.com/sinsenliu/p/9369729.html>
