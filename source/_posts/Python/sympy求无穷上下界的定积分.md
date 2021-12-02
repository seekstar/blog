---
title: sympy求无穷上下界的定积分
date: 2021-12-02 16:51:27
tags:
---

sympy中，用```oo```来表示无穷，即$\infty$。负无穷就是```-oo```，即$-\infty$。

所以求$\int_{1}^{+\infty}e^{-x}\mathrm{d}x$的python代码如下

```py
import sympy
x = sympy.symbols('x')
sympy.integrate(sympy.exp(-x), (x, 1, sympy.oo))
```

输出：

```
exp(-1)
```

参考文献：<https://stackoverflow.com/questions/44480545/why-is-using-infinity-oo-in-sympy-faster-than-providing-an-integer-upper-bound>
