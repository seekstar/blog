---
title: "cannot stat ‘./modules.builtin‘: No such file or directory"
date: 2021-07-18 16:51:57
---

```make modules_install```时报错：
```
cp: cannot stat './modules.builtin': No such file or directory
```

这是因为```make modules.builtin```时出问题了，导致这个文件没有被编译出来。再跑一遍
```shell
make modules.builtin
```
看看会报什么错。我这里报的是
```
/bin/sh: 1: flex: not found
```
所以安装一下flex，重新make就好了
```shell
sudo apt install flex
make modules.builtin
```

再尝试```make modules_install```，继续报错
```
cannot stat 'arch/x86/crypto/aegis128-aesni.ko': No such file or directory
```
同样先make一下它
```shell
make arch/x86/crypto/aegis128-aesni.ko
```
```shell
warning: Cannot use CONFIG_STACK_VALIDATION=y, please install libelf-dev, libelf-devel or elfutils-libelf-devel
```

安装依赖，再```make modules_install```，就可以了。

注：这种情况很可能是因为make前没有```make menuconfig```。如果求稳的话最好把依赖装好后重新跑一遍make。

参考文献：<https://lfs-support.linuxfromscratch.narkive.com/zgkC5Jzy/cannot-stat-modules-builtin-kernel-make-error>
