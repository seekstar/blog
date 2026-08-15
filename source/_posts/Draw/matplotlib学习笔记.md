---
title: matplotlib学习笔记
date: 2023-10-18 19:28:00
tags:
---

- {% post_link Draw/'matplotlib: **kwargs: `.Text` properties can be used to control the appearance of the labels' %}

- {% post_link Draw/'matplotlib: The PDF backend does not currently support the selected font' %}

- {% post_link Draw/'matplotlib打印微秒' %}

- {% post_link Draw/'matplotlib生成没有留白的图片' %}

- {% post_link Draw/'matplotlib箱线图调整箱子的宽度' %}

- {% post_link Draw/'matplotlib中使用latex' %}

- [python matplotlib坐标轴刻度设置](https://blog.csdn.net/gsgbgxp/article/details/125077492)

- [Python -- Matplotlib：画一条水平线或竖直线](https://blog.csdn.net/math_gao/article/details/109592302)

如果要用`plt.show()`的话，需要额外安装一些依赖：

```shell
# https://stackoverflow.com/a/77644828/13688160
pip3 install PyQt6
```

## hatch style

文档：<https://matplotlib.org/stable/gallery/shapes_and_collections/hatch_style_reference.html>

个人常用：

- '///'
- '\\\\\\'
- 'XX'
- '---'
- '--//'
- '--\\\\'
- '--XX'
- '//////'
- '\\\\\\\\\\\\'
- 'XXXX'
- '------'

## pyplot

```python
import matplotlib.pyplot as plt
```

yscale: <https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.yscale.html>

非阻塞显示图片：`plt.show(block=False)`

开始画下一张：`plt.figure()`

### 散点图 [plt.scatter](https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.scatter.html)

交互式散点图：<https://mpld3.github.io/examples/scatter_tooltip.html>

#### marker

完整列表：<https://matplotlib.org/stable/api/markers_api.html>

常用：

`o`: 圆圈

`s`: square, 正方形

`D`: diamond, 菱形

`^`: 上三角

`v`: 下三角

`<`: 左三角

`>`: 右三角

默认是圆角的。如果不想要圆角效果，可以设置`linewidth=0`。

#### legend

要用`Line2D`画: <https://stackoverflow.com/questions/47391702/how-to-make-a-colored-markers-legend-from-scratch>

调整宽度用`legend`的参数`handlelength`:

<https://stackoverflow.com/questions/66809947/matplotlib-change-length-of-legend-lines>

<https://stackoverflow.com/questions/20048352/how-to-adjust-the-size-of-matplotlib-legend-box>

### 折线图 [plt.plot](https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.plot.html)

`plt.plot(y)`的横坐标是从0开始的数组下标。

常用参数：

`linestyle`: '-' or 'solid', '--' or 'dashed', '-.' or 'dashdot', ':' or 'dotted'。完整列表：<https://matplotlib.org/stable/api/_as_gen/matplotlib.lines.Line2D.html#matplotlib.lines.Line2D.set_linestyle>

#### marker

一般可以用`marker`, `markersize`, `markerfacecolor`, `markevery`。

但是如果要手动指定哪些数据点需要marker，还是得用scatter。需要加上参数`zorder=2`手动把层级顺序调成跟线条一样，不然会出现后画的marker在先画的线条下面。

### ['plt.ylabel'](https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.ylabel.html)

- `loc`: {'bottom', 'center', 'top'}, default: `center`

其他参数传给了Text。常用的：

- `y`

可以微调高度

### [plt.text](https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.text.html)

Positional, required:

- `x, y`: float。坐标默认是左下角的坐标。

- `s`: str

Optional:

- `fontsize`

- `transform`

The default transform specifies that text is in data coords.

`transform=ax.transAxes`: in axis coords. (0, 0) is lower-left and (1, 1) is upper-right.

其他参数：

- `ha`, `va`: 控制锚点的位置。默认是左下角，也就是说上面的`x`和`y`默认是左下角的坐标。如果想指定文本中心的坐标：`ha='center', va='center'`

### [savefig](https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.savefig.html)

Positional, required:

- `fname`: str or path-like

Optional:

- `metadata`: dict

PDF可用metadata: <https://matplotlib.org/stable/api/backend_pdf_api.html#matplotlib.backends.backend_pdf.PdfPages>

`metadata={'CreationDate': None}`: 在PDF中不保存CreationDate，从而使得数据相同时生成的PDF也相同。

参考：

[PDF file generation is not deterministic - results in different outputs on the same input](https://github.com/matplotlib/matplotlib/issues/6317/)

<https://matplotlib.org/2.1.1/users/whats_new.html#reproducible-ps-pdf-and-svg-output>

## Figure

### `Figure.get_layout_engine()`

一般这样用：

```py
fig.get_layout_engine().set(...)
```

文档：<https://matplotlib.org/stable/api/layout_engine_api.html#matplotlib.layout_engine.ConstrainedLayoutEngine.set>

常用参数：

- `h_pad`: optional, float，单位英寸

图片上下边缘的padding。默认`0.04167`

- `w_pad`: optional, float, 单位英寸

图片左右边缘的padding。默认`0.04167`

- `hspace`, `wspace`: optional, float. default: 0.02

Fraction of the figure to dedicate to space between the axes. These are evenly spread between the gaps between the Axes. A value of 0.2 for a three-column layout would have a space of 0.1 of the figure width between each column.

`hspace`是纵向间距。`wspace`是横向间距。

- `rect`: optional, (float, float, float, float)

Rectangle in figure coordinates to perform constrained layout in (left, bottom, width, height), each from 0-1.

### [`plt.legend`](https://matplotlib.org/stable/api/_as_gen/matplotlib.figure.Figure.legend.html#matplotlib.figure.Figure.legend)

- [Matplotlib 放置legend(bbox_to_anchor)](https://blog.csdn.net/chichoxian/article/details/101058046)

- `loc`: str or pair of floats, default: `best`

The location of the legend.

```text
+--------------+--------------+---------------+
| 'upper left' |'upper center'| 'upper right' |
+--------------+--------------+---------------+
|'center left' |   'center'   |'center right' |
+--------------+--------------+---------------+
| 'lower left' |'lower center'| 'lower right' |
+--------------+--------------+---------------+
```

如果用了constrained layout，可以加`outside`前缀，比如`outside upper center`可以把legend放到图表的上面的中间。

- `frameon`: bool, default: rcParams["legend.frameon"] (default: True)

Whether the legend should be drawn on a patch (frame).

- `handlelength`: float, default: `2.0`

The length of the legend handles, in font-size units.

- `handletextpad`: float, default: `0.8`

The pad between the legend handle and text, in font-size units.

- `columnspacing`: float, default: `2.0`

The spacing between columns, in font-size units.

- `labelspacing`: float, default: `0.5`

The vertical space between the legend entries, in font-size units.

- `borderpad`: float, default: `0.4`

The fractional whitespace inside the legend border, in font-size units.

- `borderaxespad`: float, default: `0.5`

The pad between the Axes and legend border, in font-size units.

#### 增加线宽

```py
legend = plt.legend()
for line in legend.get_lines():
    line.set_linewidth(1.0)
```

来源：<https://stackoverflow.com/a/48296983/13688160>

## Axes

文档：<https://matplotlib.org/stable/api/axes_api.html>

```python
# https://stackoverflow.com/questions/15067668/how-to-get-a-matplotlib-axes-instance
ax = plt.gca()
```

### [tick_params](https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.tick_params.html)

```shell
ax.tick_params(axis='y', which='major', labelsize=8)
```

### [set_title](https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.set_title.html)

Positional, required: `label`

Optional: `fontdict`

### [set_xticks](https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.set_xticks.html)

Positional, required: `ticks`

Optional: `labels` (list-like)

用[tick_params](#tick_params)调labelsize。

### [set_xlabel](https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.set_xlabel.html)

跟`plt.xlabel`一样。

Positional, required: `xlabel`

Optional: `labelpad`, `fontsize`

- `loc`: {'left', 'center', 'right'}, default: rcParams["xaxis.labellocation"] (default: 'center')

比方说如果xlabel超过了右边界，可以设置`loc='right'`来让它与右边界对齐，就不会超过右边界了。

### [set_xlim](https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.set_xlim.html), [set_ylim](https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.set_ylim.html)

设置Y轴最小值：

```py
ax.set_ylim(bottom=0)
```

来源：<https://stackoverflow.com/a/22642641/13688160>

### [set_yscale](https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.set_yscale.html)

内置scale：<https://matplotlib.org/stable/api/scale_api.html#builtin-scales>

常用：`linear`, `log`

例子：

```py
ax.set_yscale('log')
# 对数坐标有时候副刻度会显示label，看着很挤，可以强制不显示副刻度的label
ax_sa.tick_params(axis='y', which='minor', labelleft=False)
```

### [annotate](https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.annotate.html) 画箭头

- `text`

- `xy`: (float, float)

The point (x, y) to annotate. The coordinate system is determined by xycoords.

- `xytext`: (float, float), default: xy

The position (x, y) to place the text at. The coordinate system is determined by textcoords.

- `xycoords`, `textcoords`: default: 'data'

完整列表见文档。这里放常用的。

| Value | Description |
| ---- | ---- |
| `data` | Use the coordinate system of the object being annotated (default) |
| `figure fraction` | Fraction of figure from lower left |
| `subfigure fraction` | Fraction of subfigure from lower left |
| `axes fraction` | Fraction of axes from lower left |

- `arrowprops`: dict, optional

<https://matplotlib.org/stable/api/_as_gen/matplotlib.patches.FancyArrowPatch.html#matplotlib.patches.FancyArrowPatch>

| Key | Description |
| ---- | ---- |
| `arrowstyle` | 默认`simple`，一般填 `->`，这样能用的选项更多 |
| `relpos` | 起点相对文本框位置。默认(0.5, 0.5)，即文本框中心 |
| `shrinkA` | 箭头起点收缩的距离。Default is 2 points |
| `shrinkB` | 箭头终点收缩的距离。Default is 2 points |
| `linewidth` | 调节箭头线宽 |

其他参数传给了Text。常用的：

- `fontsize`

- `weight`

常用值：`bold`

参考：<https://stackoverflow.com/questions/36162414/how-to-add-bold-annotated-text-to-a-plot>

### [ticklabel_format](https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.ticklabel_format.html)

比如把tick设置成$\times 10^4$：

```py
ax.ticklabel_format(style='sci', scilimits=(4, 4), useMathText=True)
```

### tick formatter

文档：<https://matplotlib.org/stable/gallery/ticks/tick-formatters.html>

例子：

```python
ax1.xaxis.set_major_formatter(lambda x, pos: str(x-5))
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

### [set_label_coords](https://matplotlib.org/stable/api/_as_gen/matplotlib.axis.Axis.set_label_coords.html)

例子：

```py
ax.xaxis.set_label_coords(0.1, -0.19)
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

## [colorbar](https://matplotlib.org/stable/api/colorbar_api.html#module-matplotlib.colorbar)

<https://matplotlib.org/stable/users/explain/colors/colormapnorms.html>

例子：

```py
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm, colors

ax = plt.gca()
cmap = plt.get_cmap('coolwarm')

# need to normalize because color maps are defined in [0, 1]
norm = colors.TwoSlopeNorm(1, vmin=0, vmax=5)

norm_cmap = cm.ScalarMappable(norm=norm, cmap=cmap)

for i in np.linspace(0, 5, 100):
    plt.scatter(i, i, color=norm_cmap.to_rgba(i))
cb = plt.colorbar(norm_cmap, ax=ax, ticks=[0, 0.5, 1, 2, 3, 4, 5])
cb.ax.tick_params(labelsize=8)
plt.show()
```

参考：

<https://stackoverflow.com/questions/73510185/how-to-add-colorbar-in-matplotlib>

<https://stackoverflow.com/questions/29074820/how-do-i-change-the-font-size-of-ticks-of-matplotlib-pyplot-colorbar-colorbarbas>

## 翻转坐标轴

<https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.invert_yaxis.html>

## 子图

### 一行多列

```py
from matplotlib import gridspec

# https://matplotlib.org/stable/api/figure_api.html#matplotlib.figure.Figure
fig = plt.figure(dpi=300, figsize=(xx, xx), constrained_layout=True)
fig_sa_max.get_layout_engine().set(
    # 上下的padding
    h_pad=0.01,
    # 左右的padding
    w_pad=0.01,
    # 左，下，宽，高。一般上面预留出来放legend。
    rect=(0, 0, 1, 0.74),
)
# 1行2列
gs = gridspec.GridSpec(1, 2, figure=fig)
for col in range(2):
    ax = plt.subplot(gs[0, col])
    ...
fig.legend(
    loc='upper center',
    # 精确定位
    bbox_to_anchor=(0.53, 1.04),
    ...
)
fig.savefig(pdf_path, metadata={'CreationDate': None})
```

### 多行多列

```py
from matplotlib import gridspec

fig = plt.figure(dpi=300, figsize=(xx, xx), constrained_layout=True)
# 2行3列
gs = gridspec.GridSpec(2, 3, figure=fig)
# https://matplotlib.org/stable/api/layout_engine_api.html#matplotlib.layout_engine.ConstrainedLayoutEngine.set
fig.get_layout_engine().set(
    # 左右的padding
    w_pad=0.01,
    # 子图纵向间距，可以用来放子图title。
    hspace=0.13,
    # 左，下，宽，高。一般下面预留出来放子图title。上面预留出来放legend。
    rect=(0, 0.05, 1, 0.85),
)
for row in range(2):
    for col in range(3):
        ax = plt.subplot(gs[row, col])
        ...
    # 放title一般用fig.text
    fig.text(x, y, title, ...)
fig.legend(
    loc='upper center',
    # 精确定位
    bbox_to_anchor=(0.54, 1.0),
    # 跟图片上沿的距离
    borderaxespad=0.01,
    ...
)
...
fig.savefig(pdf_path, metadata={'CreationDate': None})
```

### 嵌套子图

如果是嵌套的子图，比如外面是2行2列，每个子图又是3个小子图，可以用`GridSpecFromSubplotSpec`。如果要求子图坐标轴对齐的话，就不能用`constrained_layout`了。这里我们手动配置layout。

```py
fig = plt.figure(dpi=300, figsize=(7, 2.8))
# 外面是2行2列的大子图
# https://matplotlib.org/stable/api/_as_gen/matplotlib.gridspec.GridSpec.html
outer_grid = gridspec.GridSpec(2, 2, figure=fig,
    # 左边距
    left=0.06,
    # 下边距
    bottom=0.12,
    # 右边距
    right=0.998,
    # 上边距
    top=0.93,
    # 子图横向距离
    wspace=0.2,
    # 子图纵向距离
    hspace=0.4,
)
for row in range(2):
    for col in range(2):
        # 每个子图又分为1行3列的小子图
        inner_grid = gridspec.GridSpecFromSubplotSpec(1, 3, subplot_spec=outer_grid[row, col], wspace=0.4)
        for i in range(3):
            ax = fig.add_subplot(inner_grid[i])
            ...
        # 给每个大子图加title可以这样加
        bbox = outer_grid[row, col].get_position(fig)
        fig.text(bbox.x0 + bbox.width/2, bbox.y0 - 0.07, title, ha='center', va='top')
...
fig.legend(
    loc='upper center',
    # 精确定位
    bbox_to_anchor=(0.5, 1.02),
    ...
)
fig.savefig(pdf_path, metadata={'CreationDate': None})
```

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

## 设置tick和坐标轴的间距

来源：<https://stackoverflow.com/questions/2969867/how-do-i-add-space-between-the-ticklabels-and-the-axes>

```py
ax.tick_params(axis='y', which='major', pad=0.1)
```

## 双Y轴

```py
# 手动控制颜色，不然两个ax上画出的线会出现相同颜色
color_list = plt.rcParams['axes.prop_cycle'].by_key()['color']
color_index = 0

ax1 = plt.gca()
ax1.set_ylabel('ylabel1', fontsize=8)
ax1.plot(x, y, label='legend1', color=color_list[color_index])
color_index += 1

ax2 = ax1.twinx()
ax2.set_ylabel('ylabel2', fontsize=8)
ax2.plot(x, y, label='legend2', color=color_list[color_index])
color_index += 1

lines1, labels1 = ax1.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax1.legend(lines1 + lines2, labels1 + labels2, fontsize=8)

plt.show()
```

## 疑难杂症

### `Matplotlib is currently using agg, which is a non-GUI backend, so cannot show the figure.`

```shell
sudo apt install python3-tk
```

来源：<https://stackoverflow.com/questions/56656777/userwarning-matplotlib-is-currently-using-agg-which-is-a-non-gui-backend-so>

### 在安装了`ttf-mscorefonts-installer`的情况下`matplotlib`找不到Times New Roman

```shell
sudo apt install msttcorefonts -qq
rm ~/.cache/matplotlib -rf
```

参考：<https://stackoverflow.com/questions/42097053/matplotlib-cannot-find-basic-fonts>

## 已知的问题

`plt.legend`顺序似乎只能是按列的，要改成按行只能手动reorder: <https://stackoverflow.com/questions/29639973/custom-legend-in-pandas-bar-plot-matplotlib>
