---
title: 解决装windows后原有linux无法进入的问题
date: 2020-02-26 23:56:31
---

参考：
<https://zhidao.baidu.com/question/2207476336082690428.html?qbl=relate_question_0&word=%B0%B2%D7%B0windows%BA%F3%D4%AD%D3%D0linux%BD%F8%B2%BB%C8%A5>

先进BIOS，然后启动选项里应该有linux的入口，点击之即可进入linux。如果没有linux的入口，看看这篇文章：[解决安装windows后Linux引导被覆盖的问题](https://blog.csdn.net/qq_41961459/article/details/108927627)。

然后更新grub，识别出新增的windows。

```shell
sudo  grub-mkconfig -o /boot/grub/grub.cfg
```

注：如果报错，可尝试一下grub2-mkconfig。

然后查看一下系统放在哪个磁盘，从而决定grub安装到哪个磁盘

```shell
sudo fdisk -l
```

例如要把grub安装到/dev/sda上，就运行

```shell
sudo grub-install /dev/sda
```

我的输出：

```text
Installing for x86_64-efi platform.
Installation finished. No error reported.
```

然后重启即可
