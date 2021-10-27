---
title: latex 定义带有方括号的command
date: 2019-09-19 16:42:11
---

来源：https://en.wikibooks.org/wiki/LaTeX/Macros

方括号中的参数其实就是默认参数。
使用方法：

```tex
\newcommand{name}[num][default]{definition}
```

例子：

```tex
\newcommand{\wbalTwo}[2][Wikimedia]{
  This is the Wikibook about LaTeX
  supported by {#1} and {#2}!}
% in the document body:
\begin{itemize}
\item \wbalTwo{John Doe}
\item \wbalTwo[lots of users]{John Doe}
\end{itemize}
```

输出：

```
    This is the Wikibook about LaTeX supported by Wikimedia and John Doe!
    This is the Wikibook about LaTeX supported by lots of users and John Doe!
```
