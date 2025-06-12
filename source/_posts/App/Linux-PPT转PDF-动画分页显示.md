---
title: Linux PPT转PDF 动画分页显示
date: 2025-06-10 21:20:11
tags:
---

可以使用LibreOffic的ExpandAnimations插件实现：<https://github.com/monperrus/ExpandAnimations>

首先从这里下载`ExpandAnimations-版本.oxt`

然后在LibreOffice Impress里 Tools -> Extensions -> Add，选中之前下载的`oxt`文件，点击`Open`，然后会弹出一个协议，点击`Accept`，插件就安装好了。然后点击`Close`，`Restart Now`让插件生效。

用LibreOffice Impress打开要转PDF的PPT，Tools -> Add-Ons -> Expand Animations，界面会卡死一段时间，然后会弹出对话框：`Expansion done! See file 路径`，转成的PDF就会在PPT的同级目录下，里面的动画是分页显示的。
