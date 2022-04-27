---
title: Linux SysRq
date: 2022-04-27 16:08:55
tags:
---

目前的Linux发行版一般都开启了SysRq。

```shell
cat /proc/sys/kernel/sysrq
```

如果输出非0，就说明开启了SysRq，如果输出为0，可以临时启用SysRq：

```shell
echo 1 > /proc/sys/kernel/sysrq
```

也可以在`/etc/sysctl.conf`里写入`kernel.sysrq = 1`实现在开机时自动启用SysRq。

SysRq可以通过命令行发送给内核：

```shell
echo 字母 > /proc/sysrq-trigger
```

也可以通过键盘发送给内核：同时按住`Alt`和`SysRq`键以及相应的字母。注意现在的键盘上`SysRq`键通常跟截屏键`PrtSc`是一个键。

一些常用的SysRq如下。

- b: 重启

- o: 关机

- s: 磁盘缓冲区同步

- c: 使kernel panic

- r: 把键盘设置为 ASCII 模式

- e: 向除 init 外所有进程发送 SIGTERM 信号

- i: 向除 init 外所有进程发送 SIGKILL 信号

- s: 同步所有已挂载的文件系统

- u: 重新挂载所有已挂载的文件系统为只读模式

完整列表：<https://en.wikipedia.org/wiki/Magic_SysRq_key>

常用的组合键：

- 安全重启：r e i s u b

- 安全关机：r e i s u o

这些操作之间要隔一段时间，不然可能前一个操作可能没有做完。

来源：

[linux键盘如何重启,使用 SysRq 键安全重启挂起的 Linux](https://blog.csdn.net/weixin_32008105/article/details/116960672)

<https://askubuntu.com/questions/22000/hotkey-to-shut-down-from-login-screen/22014#22014>
