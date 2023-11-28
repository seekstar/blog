---
title: matplotlib学习笔记
date: 2023-10-18 19:28:00
tags:
---

- {% post_link Draw/'matplotlib: **kwargs: `.Text` properties can be used to control the appearance of the labels' %}

- {% post_link Draw/'matplotlib: The PDF backend does not currently support the selected font' %}

- {% post_link Draw/'matplotlib打印微秒' %}

- {% post_link Draw/'matplotlib设置legend坐标' %}

- {% post_link Draw/'matplotlib生成没有留白的图片' %}

- {% post_link Draw/'matplotlib箱线图调整箱子的宽度' %}

- {% post_link Draw/'matplotlib中使用latex' %}

- [python matplotlib坐标轴刻度设置](https://blog.csdn.net/gsgbgxp/article/details/125077492)

- [Python -- Matplotlib：画一条水平线或竖直线](https://blog.csdn.net/math_gao/article/details/109592302)

- [Matplotlib 放置legend(bbox_to_anchor)](https://blog.csdn.net/chichoxian/article/details/101058046)

## pyplot

```python
import matplotlib.pyplot as plt
```

yscale: <https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.yscale.html>

非阻塞显示图片：`plt.show(block=False)`

开始画下一张：`plt.figure()`

`plt.plot(y)`的横坐标是从0开始的数组下标。

## Axes

```python
ax = plt.gca()
```

文档：<https://matplotlib.org/stable/api/axes_api.html>

来源：<https://stackoverflow.com/questions/15067668/how-to-get-a-matplotlib-axes-instance>

### `set_xlim`, `set_ylim`

文档：

<https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.set_ylim.html>

<https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.set_xlim.html>

设置Y轴最小值：

```py
ax.set_ylim(bottom=0)
```

来源：<https://stackoverflow.com/a/22642641/13688160>

### tick formatter

文档：<https://matplotlib.org/stable/gallery/ticks/tick-formatters.html>

例子：

```python
ax1.xaxis.set_major_formatter(lambda x, pos: str(x-5))
```

### grid

官方文档：<https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.grid.html>

让参考线在柱状图的柱子后面:

```py
# https://stackoverflow.com/a/68344604
ax.set_axisbelow(True)
```

给y轴画参考线：

```py
ax.grid(axis='y')
```

#### 指定指数

比如指定指数为1e-9:

```python
from matplotlib.ticker import ScalarFormatter
y_formatter = ScalarFormatter()
y_formatter.set_powerlimits((-9, -9))
ax.yaxis.set_major_formatter(y_formatter)
```

官方文档：<https://matplotlib.org/stable/api/ticker_api.html#matplotlib.ticker.ScalarFormatter.set_powerlimits>

来源：<https://stackoverflow.com/a/77442842/13688160>

设置fontsize:

```python
ax.yaxis.get_offset_text().set_fontsize(8)
```

来源：<https://stackoverflow.com/a/34228384/13688160>

## 翻转坐标轴

<https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.invert_yaxis.html>

## 子图

用gridspec

官方文档：<https://matplotlib.org/stable/api/_as_gen/matplotlib.gridspec.GridSpec.html>

官方例子：<https://matplotlib.org/stable/gallery/subplots_axes_and_figures/align_labels_demo.html#sphx-glr-gallery-subplots-axes-and-figures-align-labels-demo-py>

## 调整坐标轴label与tick label之间的空隙

用`labelpad`

官方文档：<https://matplotlib.org/3.1.1/api/_as_gen/matplotlib.pyplot.xlabel.html>

## 设置tick的个数

比如让y轴有4个tick:

```py
plt.locator_params(axis='y', nbins=4)
```

来源：<https://stackoverflow.com/a/13418954/13688160>

很坑的是，log scale用这种方式无效，需要手动设置ticks:

```py
plt.yscale('log')
# 设置成log scale似乎会清空ticks，所以要把设置ticks放后面
plt.yticks([1e5, 1e6, 1e7], fontsize=8)
# plt.yticks似乎会消除minor ticks，所以还得把它们补上
# 其中numticks比较玄学，似乎大于3就行。这里直接设置成一个大数，就肯定不会有问题了。
ax.yaxis.set_minor_locator(LogLocator(base=10, subs=np.arange(2, 10) * 0.1, numticks=233))
```

## 疑难杂症

在安装了`ttf-mscorefonts-installer`的情况下`matplotlib`找不到Times New Roman:

```shell
sudo apt install msttcorefonts -qq
rm ~/.cache/matplotlib -rf
```

参考：<https://stackoverflow.com/questions/42097053/matplotlib-cannot-find-basic-fonts>
