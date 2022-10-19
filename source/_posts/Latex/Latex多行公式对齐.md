---
title: Latex多行公式对齐
date: 2022-10-19 14:20:58
tags:
---

可以用`aligned`环境实现。对齐点用`&`标注。这个环境跟table类似，但是对齐方式是`rlrlrlrl...`，也就是说先右对齐再左对齐再右对齐，以此类推。所以如果某一列的对齐方式跟想要的不一样，在前面多插入一个`&`即可。例子：

```tex
\begin{aligned}
a &= f(x), & x > 0 \\
g(x) &= h(x)^2, & x > -233
\end{aligned}
```

效果是第1列右对齐，第二列左对齐，第三列右对齐：

$$
\begin{aligned}
a &= f(x), & x > 0 \\
g(x) &= h(x)^2, & x > -233
\end{aligned}
$$

让第三列左对齐，只需要在第二列到第三列直接多插入一个`&`，使原来的第三列变成第四列，就是右对齐了：

```tex
\begin{aligned}
a &= f(x), && x > 0 \\
g(x) &= h(x)^2, && x > -233
\end{aligned}
```

$$
\begin{aligned}
a &= f(x), && x > 0 \\
g(x) &= h(x)^2, && x > -233
\end{aligned}
$$

来源：<https://tex.stackexchange.com/questions/159723/what-does-a-double-ampersand-mean-in-latex>
