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
