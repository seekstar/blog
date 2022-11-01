---
title: vscode在选中的每行开头插入
date: 2022-11-01 18:58:45
tags:
---

首先`alt+shift+i`在选中的每行末尾创建一个光标，然后再按两下`Home`键将光标移动到每行开头，然后再插入即可。

如果vscode开启了自动换行，那么在自动换行的行也会创建光标，而这不是我们想要的。解决方案是`alt+z`临时关掉自动换行，插入完成后再`alt+z`重新开启自动换行。

参考：

<https://techstacker.com/vscode-insert-cursor-beginning-every-line/>

<https://stackoverflow.com/questions/31025502/how-can-i-switch-word-wrap-on-and-off-in-visual-studio-code>
