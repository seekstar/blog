---
title: 使得两次编译linux内核产生一样的结果
date: 2021-08-01 16:30:27
---

```shell
export INSTALL_MOD_STRIP=-s
export KBUILD_BUILD_TIMESTAMP=0
export KBUILD_BUILD_USER=root
export KBUILD_BUILD_HOST=localhost
make mrproper
make allnoconfig
make -j4
```

其中```make allnoconfig```表示除必须的选项外, 其它选项一律不选。

然后就可以发现```vmlinux```和```arch/x86/boot/bzImage```都是确定性的。需要注意的是其他文件可能仍然是不确定的。关于这两个文件的描述可以看这里：<https://en.wikipedia.org/wiki/Vmlinux>

参考文献
<https://blog.abraithwaite.net/2014/08/12/deterministic-kernel-builds/>
[Make kernel build deterministic](https://lwn.net/Articles/437864/)
[Linux Kernel内核配置方式详解](http://blog.chinaunix.net/uid-30007744-id-4597756.html)
