---
title: algorithm2e无限循环
date: 2021-11-14 11:26:48
tags: 转载
---

```tex
\documentclass{article}
\usepackage{algorithm2e}
\begin{document}
\thispagestyle{empty}

\SetKwFor{Loop}{Loop}{}{EndLoop}

\begin{algorithm}
  \Loop{}{Statement\;Statement\;}
\end{algorithm}
\end{document}
```

![](algorithm2e无限循环/2021-11-14-11-31-47.png)

原文：<https://tex.stackexchange.com/questions/148414/infinite-loop-with-algorithm2e>
