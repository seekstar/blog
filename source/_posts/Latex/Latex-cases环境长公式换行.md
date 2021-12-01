---
title: Latex cases环境长公式换行
date: 2021-12-02 00:46:59
tags:
---

cases环境中有超长公式时，换行之后可读性会更好一些。

```tex
$$
f(x) = \begin{cases}
    1 & x = 0 \\
    2333333333333333^{2333333333333333333} + 333333333333332^{333333333333333332} & x = 1
\end{cases}
$$
```

$$
f(x) = \begin{cases}
    1 & x = 0 \\
    2333333333333333^{2333333333333333333} + 333333333333332^{333333333333333332} & x = 1
\end{cases}
$$

可以通过插入```matrix```环境来实现换行：

```tex
$$
f(x) = \begin{cases}
    1 & x = 0 \\
    \begin{matrix}
        2333333333333333^{2333333333333333333} + \\
        333333333333332^{333333333333333332} \\
    \end{matrix}
    & x = 1
\end{cases}
$$
```

$$
f(x) = \begin{cases}
    1 & x = 0 \\
    \begin{matrix}
        2333333333333333^{2333333333333333333} + \\
        333333333333332^{333333333333333332} \\
    \end{matrix}
    & x = 1
\end{cases}
$$

参考文献：<https://tex.stackexchange.com/questions/182988/newline-after-cases-in-equation-environment>
