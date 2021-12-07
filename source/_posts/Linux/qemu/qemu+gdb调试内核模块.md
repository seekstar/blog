---
title: qemu+gdb调试内核模块
date: 2021-01-24 00:12:35
---

# 制作qemu虚拟机
看这里：<https://blog.csdn.net/qq_41961459/article/details/112798115>
如果是PC的话，就不用配置vnc了。

虚拟机配置完毕后要把```-enable-kvm```去掉再重启，不然软件断点不起作用。此外，加上```-s```以启动gdbserver。
```shell
sudo qemu-system-x86_64 -m 4096 centos.img -net nic -net tap,ifname=tap0,script=no,downscript=no -s
```
关掉了kvm之后开机特别慢，我这要两百多秒。

# 设置nokaslr
<https://blog.csdn.net/qq_41961459/article/details/112983233>

# 编译内核模块
Makefile里加上
```
ccflags-y += -g -DDEBUG -O1
```
不能用```-O0```，可能会报错。

# 配置gdb
在~/.gdbinit里加上
```
add-auto-load-safe-path /full_path_to_kernel_build_dir/scripts/gdb/vmlinux-gdb.py
```
例如
```
add-auto-load-safe-path /mnt/hdd/kernel/gdb/linux-nova/scripts/gdb/vmlinux-gdb.py
```
这样gdb里就可以用```lx-symbols```了。
# gdb连上qemu并设置自动加载模块符号
```shell
cd /path/to/kernel/build/dir
gdb vmlinux
```
然后在gdb里执行
```gdb
target remote :1234
```
输出：
```
0xffffffff827302c2 in native_safe_halt () at ./arch/x86/include/asm/irqflags.h:57
57              asm volatile("sti; hlt": : :"memory");
```
然后设置自动加载模块符号，在gdb里继续执行：
```gdb
lx-symbols path/to/parent/of/modules/
```
输出：
```
loading vmlinux
scanning for modules in /home/searchstar/git/projects/nova/
scanning for modules in /mnt/hdd/kernel/gdb/linux-nova
loading @0xffffffffc1090000: /mnt/hdd/kernel/gdb/linux-nova/arch/x86/kernel/msr.ko
loading @0xffffffffc1088000: /mnt/hdd/kernel/gdb/linux-nova/net/netfilter/nft_fib_inet.ko
loading @0xffffffffc1080000: /mnt/hdd/kernel/gdb/linux-nova/net/ipv4/netfilter/nft_fib_ipv4.ko
此处省略若干行
loading @0xffffffffc0000000: /mnt/hdd/kernel/gdb/linux-nova/fs/autofs/autofs4.ko
```

# insmod
在gdb里输入c
```
(gdb) c
Continuing.
```
这样虚拟机就会继续运行。在虚拟机中用insmod加载模块。这时gdb会自动加载内核模块的符号。

# 在gdb中设置断点
由于已经关闭了```kvm```，所以可以直接设置软断点。
```
(gdb) b nova_init_blockmap
Breakpoint 1 at 0xffffffffc10992ab: file /home/searchstar/git/projects/nova/balloc.c, line 212.
```

# 跑起来
```
(gdb) c
Continuing.

Breakpoint 1, nova_init_blockmap (sb=0xffff88809ee9cb08)
    at /home/searchstar/git/projects/nova/balloc.c:212
212     {
(gdb) n
213             struct nova_sb_info *sbi = NOVA_SB(sb);
(gdb) n
214             unsigned long mask_bits = ceil_log_2(sbi->num_blocks);
(gdb) n
224             while (a * 5 < (1 << max_bits_a)) {
```
