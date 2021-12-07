---
title: matplotlib设置legend坐标
date: 2021-01-01 16:21:16
---

使用plt.legend的loc参数。
```py
plt.legend([str1, str2, str3], loc = [x, y])
```
其中x和y默认是百分比（写成0到1的小数），设定legend的左下角在图中的位置。
