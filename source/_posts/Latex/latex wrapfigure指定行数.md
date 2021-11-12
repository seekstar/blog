---
title: latex wrapfigure指定行数
date: 2020-04-20 15:45:27
tags:
---

网上很多都是错的。。。

wrapfigure的自动高度计算往往偏高，有时会导致图片在上一页的末尾时下一页的文字被绕排（其实图片没有延伸到下一页），这时就需要手动指定行数了。

宏包：
```tex
\usepackage{wrapfig}
```

用法：
```
\begin{wrapfigure}[行数]{位置}{超出长度}{宽度}<图形>\end{wrapfigure}
```
注意，行数两边是方括号，不是花括号！

其他的看这里
<https://www.jianshu.com/p/dc168489b0fc>

示例：
```tex
\begin{wrapfigure}[16]{r}{0.5\textwidth}
    \centering
    \includegraphics[width=0.5\textwidth]{img/温度点示意图.png}
    \caption{温度点示意图}\label{温度点示意图}
\end{wrapfigure}
```
