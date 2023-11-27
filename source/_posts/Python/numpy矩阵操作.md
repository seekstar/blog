---
title: numpy矩阵操作
date: 2021-08-20 22:09:42
---

numpy官方文档：<https://numpy.org/doc/stable/>

```shell
pip install numpy
```

```py
import numpy as np
```

## 矩阵定义

$$
\left[
	\begin{matrix}
		1 & 2 \\
		3 & 4
	\end{matrix}
\right]
$$

```py
a = np.array([[1,2],[3,4]])
```

## reshape

<https://numpy.org/doc/stable/reference/generated/numpy.reshape.html>

## 求行列式

```py
np.linalg.det(a)
```

LINear ALGebra

## 矩阵拼接

竖直拼接用vstack:

```py
res = np.zeros((0, 3)) # 0行3列的矩阵
res = np.vstack([res, [1, 2, 3]])
res = np.vstack([res, [4, 5, 6]])
res
```

```text
array([[1., 2., 3.],
       [4., 5., 6.]])
```

水平拼接用hstack，语法跟上面的一样。

## 求均值

```py
m = np.array([[1., 2., 3.], [4., 5., 6.]])
m.mean() # 整个矩阵所有值的平均数
m.mean(axis=0) # 将第0维干掉。实际上就是求每列的平均数
m.mean(axis=1) # 将第1维干掉。实际上就是求每行的平均数
```

要求标准差的话，把上面的`mean`换成`std`即可。

## 每隔n个元素求均值

```py
import numpy as np
a = np.array([1, 4, 2, 3, 5, 6])
n = 2
a.reshape(-1, n).mean(axis=1)
```

如果长度不是n的倍数的话，只能这样：

```py
def mean_every_n(a, n):
	split = len(a) - len(a) % n
	res = a[0:split].reshape(-1, n).mean(axis=1)
	if split != len(a):
		res = np.append(res, a[split:].mean())
	return res
mean_every_n(a, 4)
```

参考：<https://www.geeksforgeeks.org/averaging-over-every-n-elements-of-a-numpy-array/#>

## 每列除以某个向量

```py
matrix = np.array([[1, 2, 3],
                   [4, 5, 6],
                   [7, 8, 9]])
vector = np.array([1, 2, 3])
# vector.shape == (3,)，只有一个维度
# 加一个维度
column_vector = vector[:, np.newaxis]
# column_vector.shape == (3, 1)
# 这个时候做除法，numpy会自动对column_vector做broadcasting
matrix / column_vector
```

```text
array([[1.        , 2.        , 3.        ],
       [2.        , 2.5       , 3.        ],
       [2.33333333, 2.66666667, 3.        ]])
```

## 参考文献

[python中矩阵的用法](https://www.cnblogs.com/abella/p/10207945.html)
[numpy创建矩阵常用方法](https://blog.csdn.net/zhouweiyu/article/details/78806711)
[numpy.mean() 计算矩阵均值](https://blog.csdn.net/chixujohnny/article/details/51106421)
