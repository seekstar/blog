---
title: Latex导入pgf图片
date: 2021-01-01 17:17:47
---

转自：<https://tex.stackexchange.com/questions/117042/set-the-size-of-pgf-picture>
```tex
			\begin{figure}\label{HPL}
                \resizebox{\textwidth}{!}{\input{img/HPL.pgf}}
            \caption{HPL}
            \end{figure}
```
