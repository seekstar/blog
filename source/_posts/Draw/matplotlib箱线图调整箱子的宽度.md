---
title: matplotlib箱线图调整箱子的宽度
date: 2021-05-08 10:02:18
---

```
widths : array-like, default = 0.5
Either a scalar or a vector and sets the width of each box. The default is 0.5, or 0.15*(distance between extreme positions) if that is smaller.
```
例子：
```py
import numpy as np
import matplotlib.pyplot as plt

np.random.seed(937)
data = np.random.lognormal(size=(37, 4), mean=1.5, sigma=1.75)
labels = list('ABCD')
fs = 10  # fontsize

plt.boxplot(data, labels=labels, showfliers=False, widths=(1, 0.5, 1.2, 0.1))

plt.show()
```

原文：<https://stackoverflow.com/questions/32443803/adjust-width-of-box-in-boxplot-in-python-matplotlib>
