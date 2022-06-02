---
title: vscode右键异常
date: 2022-05-17 15:08:03
tags:
---

右键菜单出现之后，似乎会立即选中离鼠标最近的那项，然后右键菜单消失。

原理好像是有些插件更改了菜单之后，菜单会出现在光标下面，然后右键松开之后，就进入这个菜单项了：

<https://github.com/microsoft/vscode/issues/113175>

<https://stackoverflow.com/questions/66419930/the-popup-menu-coming-on-right-click-disappears-instantly-in-vscode>

所以将所有会更改右键菜单的插件全部禁用就行，比如Jupyter插件。很多人说使用easystroke也可以解决：<https://askubuntu.com/questions/10586/right-click-menu-on-mouse-release-windows-behavior/470219#470219>。但是ArchLinux上用yay安装easystroke会编译失败。

也可以记住右键菜单里的项的快捷键，然后直接用快捷键，不用右键菜单就行了。
