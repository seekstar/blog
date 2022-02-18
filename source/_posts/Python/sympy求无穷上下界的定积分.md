---
title: sympy求无穷上下界的定积分
date: 2021-12-02 16:51:27
tags:
---

sympy中，用`oo`来表示无穷，即$\infty$。负无穷就是`-oo`，即$-\infty$。

这里以$\int_{1}^{+\infty}e^{-x}\mathrm{d}x$为例给出求无穷上下界定积分的解析解和数值解的方法。

## 解析解

用`integrate`。用法为`integrate(函数，（变量，下限， 上限）)`。



```py
import sympy
x = sympy.symbols('x')
sympy.integrate(sympy.exp(-x), (x, 1, sympy.oo))
```

输出：

```
exp(-1)
```

即$e^{-1}$。

但是这个函数有时候会抽风，明明是有值的会被算成无穷大。

## 数值解

用`Integral`。用法为`Integral(函数，（变量，下限， 上限）)`。但是这个只是一个表达式，对这个表达式再调用`evalf`就可以求出以浮点数表示的值。

```py
import sympy
x = sympy.symbols('x')
sympy.Integral(sympy.exp(-x), (x, 1, sympy.oo)).evalf()
```

```
0.367879441171442
```

这就是$e^{-1}$的数值。

## 参考文献

[Python求积分（定积分）](https://blog.csdn.net/a19990412/article/details/80574212)

<https://stackoverflow.com/questions/44480545/why-is-using-infinity-oo-in-sympy-faster-than-providing-an-integer-upper-bound>

[用python的库 sympy 求积分](https://blog.csdn.net/t4ngw/article/details/105770161)
