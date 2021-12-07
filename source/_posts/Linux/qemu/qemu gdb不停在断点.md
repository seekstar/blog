---
title: qemu gdb不停在断点
date: 2021-01-22 21:59:13
---

首先要保证是在
```shell
target remote :1234
```
之后设置的断点。

如果使用了```-enable-kvm```，就必须要设置硬件断点，gdb命令为hbreak，缩写为hb。注意硬件断点需要硬件支持，所以不一定有效。

如果是在内核模块里的断点，还需要按以下顺序进行操作：

1. 编译带有debug symbol的内核模块
```Makefile
ccflags-y += -g -DDEBUG -O1
```
不能用```-O0```，可能会报错。

2. 让gdb自动加载内核模块的符号

先在```~/.gdbinit```里加上
```
add-auto-load-safe-path /full_path_to_kernel_build_dir/scripts/gdb/vmlinux-gdb.py
```
例如
```
add-auto-load-safe-path /mnt/hdd/kernel/gdb/linux-nova/scripts/gdb/vmlinux-gdb.py
```
这样gdb里的```lx-symbols```就可以用了。

然后在gdb里执行：
```gdb
lx-symbols path/to/parent/of/modules/
```

3. insmod

在虚拟机里insmod。这时gdb会自动加载内核模块的符号

4. 在gdb中设置断点

# 参考文献
<https://cloud.tencent.com/developer/article/1613356>
<https://stackoverflow.com/questions/18931727/remote-gdb-debugging-does-not-stop-at-breakpoints>
<https://stackoverflow.com/questions/61568572/cant-get-gdb-to-stop-at-breakpoint-in-linux-kernel-running-under-qemu>
[内核模块里的断点注意事项](https://stackoverflow.com/questions/28607538/how-to-debug-linux-kernel-modules-with-qemu)
