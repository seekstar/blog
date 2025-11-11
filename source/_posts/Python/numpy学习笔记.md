---
title: numpy学习笔记
date: 2023-11-17 16:53:50
tags:
---

官方文档：<https://numpy.org/doc/stable/>

## numpy.array

### 从python list创建

```python
np.array([1, 2, 3])
```

### 从多个python list创建一维数组

如果是确定数量的list，可以用`np.concatenate`:

```python
a = [1, 2, 3]
b = [4, 5, 6]
np.concatenate((a, b))
```

输出：`array([1, 2, 3, 4, 5, 6])`

来源：<https://stackoverflow.com/a/54773471/13688160>

如果有不定数量的list，用迭代器：

```python
listOfLists = [[1, 2, 3], [4, 5, 6]]
np.array([ elem for singleList in listOfLists for elem in singleList])
```

输出：

```text
array([1, 2, 3, 4, 5, 6])
```

来源：<https://thispointer.com/python-numpy-create-a-ndarray-from-list-tuple-or-list-of-lists-using-numpy-array/>

### 等差数列

#### [numpy.linspace](https://numpy.org/doc/stable/reference/generated/numpy.linspace.html)

指定个数

```py
numpy.linspace(start, stop, num=50, endpoint=True, retstep=False, dtype=None, axis=0)
```

#### [numpy.arange](https://numpy.org/doc/stable/reference/generated/numpy.arange.html)

指定差

```py
numpy.arange([start,] stop, [step,] *)
```

start: default 0

step: default 1

### 二分搜索

<https://numpy.org/doc/stable/reference/generated/numpy.searchsorted.html>

left相当于lower_bound, right相当于upper_bound, 默认是left。

## 矩阵

- {% post_link Python/'numpy矩阵操作' %}

## percentile

<https://numpy.org/doc/stable/reference/generated/numpy.percentile.html#>

```py
# 10000个0到1的随机数
a = np.random.rand(10000)
# 求20%分位数，即小于此数的值的数量占总数的20%
np.percentile(a, 20)
# 求多个分位数
np.percentile(a, [10, 20, 30, 40, 50, 60, 70, 80, 90, 99, 99.9, 99.99])
```
