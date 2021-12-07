---
title: latex tabular自动换行
date: 2021-01-01 13:20:23
---

转载自：<https://tex.stackexchange.com/questions/166743/automatic-line-break-in-tabular>

使用tabularx
```tex
\documentclass[danish,a4paper,twoside,11pt]{report}

\usepackage{tabularx}

\begin{document}
\begin{table}[h]
\begin{tabularx}{\textwidth}{|l|X|}
Use Case Navn:          & Opret Server \\
Scenarie:               & At oprette en server med bestemte regler som tillader folk at spille sammen. More Text more text More Text \\
\end{tabularx}
\end{table}
\end{document} 
```
![在这里插入图片描述](latex%20tabular自动换行/20210101131812716.png)
其中```X```表示占满剩下的宽度。

其实tabularx可以在table环境外使用，像tabular一样。所以上面的代码可以简化为
```tex
\documentclass[danish,a4paper,twoside,11pt]{report}

\usepackage{tabularx}

\begin{document}
\begin{tabularx}{\textwidth}{|l|X|}
Use Case Navn:          & Opret Server \\
Scenarie:               & At oprette en server med bestemte regler som tillader folk at spille sammen. More Text more text More Text \\
\end{tabularx}
\end{document} 
```
