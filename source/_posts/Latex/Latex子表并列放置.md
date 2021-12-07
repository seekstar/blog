---
title: Latex子表并列放置
date: 2021-04-29 18:45:08
---

```tex
\usepackage{caption}
\usepackage{subcaption}
```

```tex
\begin{table}
    \centering
    \begin{subtable}[t]{0.495\linewidth}
        \begin{tabular}{ccc}
            \toprule
            Dup(\%) & Tree & Array \\
            \midrule
            0 & & \\
            20 & & \\
            40 & & \\
            60 & & \\
            80 & & \\
            \bottomrule
        \end{tabular}
        \caption{Thread count is 1}
    \end{subtable}
    \begin{subtable}[t]{0.495\linewidth}
        \begin{tabular}{ccc}
            \toprule
            Thread\# & Tree & Array \\
            \midrule
            1 & & \\
            2 & & \\
            4 & & \\
            8 & & \\
            16 & & \\
            \bottomrule
        \end{tabular}
        \caption{Dup ratio is 0\%}
    \end{subtable}
    \caption{Caption here}
    \label{tab:array}
\end{table}
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210429184336642.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxOTYxNDU5,size_16,color_FFFFFF,t_70)
参考文献：
<https://tex.stackexchange.com/questions/2832/how-can-i-have-two-tables-side-by-side>
