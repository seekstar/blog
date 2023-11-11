---
title: matplotlib学习笔记
date: 2023-10-18 19:28:00
tags:
---

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

## Axes

```python
ax = plt.gca()
```

文档：<https://matplotlib.org/stable/api/axes_api.html>

来源：<https://stackoverflow.com/questions/15067668/how-to-get-a-matplotlib-axes-instance>

### tick formatter

文档：<https://matplotlib.org/stable/gallery/ticks/tick-formatters.html>

例子：

```python
ax1.xaxis.set_major_formatter(lambda x, pos: str(x-5))
```

#### 指定指数

比如指定指数为1e-9:

```python
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

## gridspec

官方文档：<https://matplotlib.org/stable/api/_as_gen/matplotlib.gridspec.GridSpec.html>

官方例子：<https://matplotlib.org/stable/gallery/subplots_axes_and_figures/align_labels_demo.html#sphx-glr-gallery-subplots-axes-and-figures-align-labels-demo-py>

## 疑难杂症

在安装了`ttf-mscorefonts-installer`的情况下`matplotlib`找不到Times New Roman:

```shell
sudo apt install msttcorefonts -qq
rm ~/.cache/matplotlib -rf
```

参考：<https://stackoverflow.com/questions/42097053/matplotlib-cannot-find-basic-fonts>
