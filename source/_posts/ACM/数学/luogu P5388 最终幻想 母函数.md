---
title: P5388 最终幻想 母函数
date: 2021-11-15 13:35:39
tags:
---

[yamengxi](https://www.luogu.com.cn/blog/yamengxi/solution-p5388)大佬写了一个优美的公式，但是没有给出证明。时隔两年，本蒟蒻终于可以帮大佬补个证明了。

假设答案是$f_n(k)$，那么根据[c__z__a](https://www.luogu.com.cn/blog/401583/solution-p5388)的题解，可以得到以下递推表达式：

$$f_n(k) = \begin{cases}
\sum_{i=0}^{k-1}f_{n-1}(i) + 1 & n > 1 \\
k + 1 & n = 1
\end{cases}$$

下面用母函数来求$f_n(k)$的通项。设

$$G_n(x) = \sum_{k=0}^{\infty}f_n(k) x^k$$

那么有

$$\begin{aligned}
G_1(x) =& \sum_{k=0}^{\infty}f_1(k) x^k \\
=& \sum_{k=0}^{\infty}(k+1)x^k \\
=& (\sum_{k=0}^{\infty}x^{k+1})' \\
=& (\sum_{k=1}^{\infty}x^k)' \\
=& (\sum_{k=0}^{\infty}x^k - 1)' \\
=& (\frac{1}{1-x} - 1)' \\
=& \frac{1}{(1-x)^2}
\end{aligned}$$

$n>1$时，有

$$\begin{aligned}
G_n(x) =& \sum_{k=0}^{\infty}f_n(k) x^k \\
=& \sum_{k=0}^{\infty}(\sum_{i=0}^{k-1}f_{n-1}(i) + 1)x^k \\
=& \sum_{k=0}^{\infty}x^k + \sum_{k=0}^{\infty}(\sum_{i=0}^{k-1}f_{n-1}(i))x^k \\
=& \frac{1}{1-x} + x\sum_{k=0}^{\infty}(\sum_{i=0}^k f_{n-1}(i))x^k \\
=& \frac{1}{1-x} + x(\sum_{k=0}^{\infty}f_{n-1}(k)x^k)(\sum_{k=0}^{\infty}x^k) \\
=& \frac{1}{1-x} + \frac{x}{1-x}G_{n-1}(x)
\end{aligned}$$

所以

$$G_2(x) = \frac{x}{(1-x)^3} + \frac{1}{1-x}$$

$$G_3(x) = \frac{x^2}{(1-x)^4} + \frac{x}{(1-x)^2} + \frac{1}{1-x}$$

$$\begin{aligned}
G_n(x) =& \frac{x^{n-1}}{(1-x)^{n+1}} + \sum_{i=0}^{n-2}\frac{x^i}{(1-x)^{i+1}} \\
=& \frac{x^{n-1}}{(1-x)^{n+1}} + \frac{1}{1-x} \frac{1-\frac{x^{n-1}}{(1-x)^{n-1}}}{1-\frac{x}{1-x}} \\
=& \frac{x^{n-1}}{(1-x)^{n+1}} + \frac{1-\frac{x^{n-1}}{(1-x)^{n-1}}}{1-2x} \\
=& \frac{1}{1-2x} + \frac{x^{n-1}}{(1-x)^{n+1}} - \frac{1}{1-2x} \frac{x^{n-1}}{(1-x)^{n-1}} \\
=& \frac{1}{1-2x} + \frac{x^{n-1}}{(1-x)^{n-1}} (\frac{1}{(1-x)^2} - \frac{1}{1-2x}) \\
=& \frac{1}{1-2x} + \frac{x^{n-1}}{(1-x)^{n-1}} \frac{-x^2}{(1-2x)(1-x)^2} \\
=& \frac{1}{1-2x} - \frac{1}{1-2x} \frac{x^{n+1}}{(1-x)^{n+1}}
\end{aligned}$$

$\frac{1}{1-2x}$的第$k$项是$2^k$，$\frac{1}{(1-x)^{n+1}}$的第$k$项是$C_{n+k}^{n}$，所以$\frac{1}{1-2x} \frac{1}{(1-x)^{n+1}}$的第$k$项是$\sum_{i=0}^k C_{n+i}^{n} 2^{k-i}$，所以$\frac{1}{1-2x} \frac{x^{n+1}}{(1-x)^{n+1}}$的第$k$项是

$$\begin{cases}
0 & k \le n \\
\sum_{i=0}^{k-n-1} C_{n+i}^{n} 2^{k-n-1-i} & k > n
\end{cases}$$

所以$G_n(x)$的第$k$项是

$$\begin{cases}
2^k & k \le n \\
2^k - \sum_{i=0}^{k-n-1} C_{n+i}^{n} 2^{k-n-1-i} & k > n
\end{cases}$$

~~咦？怎么跟yamengxi的不太一样？~~

此外，我完全看不出这个东西怎么能化简到$\sum_{i=0}^n C_k^i$，希望未来有大佬可以补上这个证明。
