---
title: 修复Windows引导
date: 2022-04-24 00:39:12
tags:
---

本博客是修复以后凭记忆写的，记忆不一定准确。

情况：原先有两个windows，然后把其中一个windows连同EFI分区全部删掉了，只剩下另一个windows及其system reserved分区。在Linux上进行`update-grub`没有办法识别出这个windows系统，因此这个windows系统无法出现在grub界面，也无法以其他方式进入。

首先我尝试了rescatux里的重新安装windows EFI，为此甚至修复了rescatux无法处理NVMe分区的BUG。然后`/boot/efi/EFI/`目录里多了个`Microsoft`的文件夹，里面有几个文件。但是`update-grub`之后仍然无法识别出windows系统。

受rescatux启发，我把另一台电脑上的`/boot/efi/EFI/Microsoft`拷贝到这台出问题的电脑上的`/boot/efi/EFI/Microsoft`里，然后`update-grub`，这时识别出了`windows boot manager`。但是在grub界面选择`windows boot manager`进去之后，又报错`你的电脑/设备需要修复`。

然后我烧了个windows启动盘，进去之后不安装，而是选择`修复这台计算机`，选择`疑难解答`，选择`引导修复`。但是显示无法修复。然后我进入命令提示符，按照这篇文章的方式修复：<http://www.xiaoyuxitong.com/windows10/49943.html>。但是执行到`BOOTREC /FIXBOOT`的时候报错`拒绝访问`。

然后尝试用这篇文章的方式来修复这个`拒绝访问`的问题：<https://vrshendeng.com/1557.html>。发现还是`拒绝访问`。

然后尝试这个：<https://blog.csdn.net/xw988tom/article/details/118788664>，先切换到`C:`，然后运行`bootsect /nt60 sys`，再运行`BOOTREC /FIXBOOT`，然后就成功了。（但是如果在`K:`下，就无效？）然后我忘了再运行一下`BOOTREC /REBUILDBCD`，导致`K:`还是空的。然后我好像在windows启动盘里选择`继续使用windows`，就进windows了。而且重启之后也是可以直接进windows。

虽然成功修复了，但是其实不是很清楚是什么原理。

现在回过头来，应该直接`bootsect /nt60 sys`，然后`BOOTREC /FIXBOOT`，而不必格式化EFI分区。或者从一开始就尝试windows启动盘里的`继续使用windows`能不能启动电脑里的windows。

用这种方法修复windows引导之后，原先的Linux引导大概率已经被破坏了，开机会直接进Windows。修复Linux引导的方法看这里：{% post_link Other/Windows/'解决安装windows后Linux引导被覆盖的问题' %}
