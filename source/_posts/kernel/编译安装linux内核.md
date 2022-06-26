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

## 安装到系统目录

### 内核模块

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

### 内核

```shell
make install
```

如果有类似于这样的报错：

```text
没有规则可制作目标“certs/rhel.pem”，由“certs/x509_certificate_list” 需求。
```

那可能要把`.config`里的`CONFIG_SYSTEM_TRUSTED_KEYS`后面引号里的东西删掉。

另外要注意看看有没有要我们安装`console-setup`和`plymouth-themes`的提示。

### （可选）用于编译内核模块的文件

这个安装的头文件只能给用户态程序用，不能用于编译内核模块：

```shell
# make INSTALL_HDR_PATH=指定目录 headers_install
make headers_install
```

如果用包管理器安装`linux-headers-xxx`的话，会把头文件安装在`/usr/src/linux-headers-xxx-amd64`和`/usr/src/linux-headers-xxx-common`下面，里面有用的只有这几个文件或文件夹：

```text
arch/x86/include/ arch/x86/Makefile* include/ Makefile Module.symvers scripts/ tools/
```

所以如果要安装用于编译内核模块的文件到系统目录，只需要把这些文件或文件夹放进`/usr/src/linux-headers-我们编译的内核版本`即可。

之前安装的内核模块的目录`/usr/lib/modules/我们编译的内核版本`里的`build`和`source`符号链接原先是指向编译时使用的源码的路径，现在改到`/usr/src/linux-headers-我们编译的内核版本/`即可。

## 安装到指定目录

这样可以在服务器上编译内核，安装到`指定目录`，然后`指定目录`打包传到目标机器，再安装到目标机器上的系统目录即可。

### 内核模块

把内核模块安装到`指定目录/lib/modules/xxx`：

```shell
INSTALL_MOD_PATH=指定目录 make modules_install
#INSTALL_MOD_PATH=指定目录 make INSTALL_MOD_STRIP=1 modules_install
```

### 内核

把`System.map-xxx`和`vmlinuz-xxx`安装到`指定目录`下面：

```shell
INSTALL_PATH=指定目录 make install
```

会报错：

```text
ln: 无法创建符号链接'/boot/System.map': 权限不够
ln: 无法创建符号链接'/boot/vmlinuz': 权限不够
ln: 无法创建符号链接'/boot/System.map': 权限不够
```

不用管这个报错，因为我们不安装到系统目录。

### （可选）用于编译内核模块的文件

把这些文件安装到`指定目录/linux-headers`：

```shell
mkdir -p 指定目录/linux-headers/arch/x86/
cp -r arch/x86/include/ arch/x86/Makefile* 指定目录/linux-headers/arch/x86/
cp -r include/ Makefile Module.symvers scripts/ tools/ 指定目录/linux-headers/
```

### 在目标机器上安装到系统目录

在编译服务器上把`指定目录`压缩，传输到目标机器上，解压出来，进入`指定目录`，然后执行以下指令来安装到目标机器上的系统目录里：

```shell
kernel_version_to_install=$(ls lib/modules/)
# 内核模块
sudo cp -r lib/modules/$kernel_version_to_install /lib/modules/
# 内核
sudo cp -r vmlinuz-* System.map-* /boot/
# 生成initramfs
sudo update-initramfs -ck $kernel_version_to_install
# 更新GRUB
sudo update-grub
# （可选）安装用于编译内核模块的文件
sudo rm -rf /usr/src/linux-headers-$kernel_version_to_install
sudo cp -r linux-headers/ /usr/src/linux-headers-$kernel_version_to_install
sudo rm /lib/modules/$kernel_version_to_install/build /lib/modules/$kernel_version_to_install/source
sudo ln -s /usr/src/linux-headers-$kernel_version_to_install /lib/modules/$kernel_version_to_install/build
sudo ln -s /usr/src/linux-headers-$kernel_version_to_install/ /lib/modules/$kernel_version_to_install/source
```

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
