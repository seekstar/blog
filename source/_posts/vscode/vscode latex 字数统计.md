---
title: vscode latex 字数统计
date: 2020-04-15 23:25:58
tags:
---

安装插件LaTeX Utilities

![在这里插入图片描述](vscode%20latex%20字数统计/20200415232342987.png)

然后打开.tex文件，状态栏中就有总字数

![在这里插入图片描述](vscode%20latex%20字数统计/20200415232440388.png)

如果项目有多个tex文件，比如有`introduction.tex`, `background.tex`，然后在`main.tex`里`\input{introduction.tex}`和`\input{background.tex}`，那么在`introduction.tex`里显示的字数是introduction的字数，在`background.tex`里显示的字数是background的字数，在`main.tex`里显示的字数是所有文件的总字数。

## 存在的问题

貌似表格里的字符数不会被统计进去。
