---
title: 编译安装linux内核
date: 2020-12-28 13:58:21
---

## 下载内核

<https://www.kernel.org/>

![在这里插入图片描述](编译安装linux内核/20201228134406637.png)

一般下载tarball，也就是.tar.xz格式的源码包。如果`/`够大，可以直接解压到`/usr/src`，也可以解压到机械盘上。

## 配置

### 编辑`.config`

一些常用的配置：

#### KASAN

KASAN是一个动态检测内存错误的工具：[在Linux内核使用Kasan](https://blog.csdn.net/weiqifa0/article/details/120359407)

```text
CONFIG_SLUB_DEBUG=y
CONFIG_KASAN=y
```

### make menuconfig

如果手动编辑了`.config`的话，这一步可能会根据手动编辑的内容调整一些其他选项，比如如果设置了`CONFIG_KASAN=y`，执行`make menuconfig`后会自动加上`CONFIG_KASAN_GENERIC=y`和`CONFIG_KASAN_OUTLINE=y`。

```shell
sudo apt install -y flex bison libelf-dev
make menuconfig
```

如果没有特殊需求，可以直接按右键头选中Exit

![在这里插入图片描述](编译安装linux内核/20201228134609864.png)

然后按enter，选保存即可。

## make

多线程编译

```shell
make -j$(nproc) > /dev/null
```

`> /dev/null`是为了防止warning和error被刷掉，比如让我们装`libelf-dev`的警告。

## 安装内核模块

如果没有特殊需求，一般可以把内核模块的debug信息给去掉，节约安装空间。

```shell
make INSTALL_MOD_STRIP=1 modules_install > /dev/null
```

注意对于centos不能`INSTALL_MOD_STRIP=1`，不然启动貌似会出问题。应该

```shell
make modules_install
```

然后再用这里的方法去`/usr/lib/modules`里手动把debug信息去掉：

{% post_link kernel/'解决编译安装内核时-lib-modules过大的问题' %}

## 安装

```shell
make install
```

如果有类似于这样的报错：

```text
没有规则可制作目标“certs/rhel.pem”，由“certs/x509_certificate_list” 需求。
```

那可能要把`.config`里的`CONFIG_SYSTEM_TRUSTED_KEYS`后面引号里的东西删掉。

另外要注意看看有没有要我们安装`console-setup`和`plymouth-themes`的提示。

## 更新grub

一般`make install`的时候会自动做。但是如果电脑上装了多个linux，那选系统界面的grub可能不是当前系统提供的，这个时候就要去提供grub的那个系统做一次`update-grub`才行。

对于centos，`make install`的时候好像不会自动更新grub，需要手动更新：

```shell
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

然后设置默认内核

```shell
sudo grubby --set-default=/boot/vmlinuz-xxxx
```

## 删除旧内核（可选）

<https://www.cnblogs.com/amanlikethis/p/3599170.html>

## 参考文献

[make[1]: *** 没有规则可制作目标“debian/canonical-certs.pem”，由“certs/x509_certificate_list” 需求。 停止。](https://blog.csdn.net/Chenciyuan_nj/article/details/115099040)
