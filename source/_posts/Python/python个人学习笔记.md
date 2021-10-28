---
title: python个人学习笔记
date: 2020-03-22 00:16:52
---

# 官方文档

<https://numpy.org/doc/stable/>

# for循环
0到9循环：
```py
for i in range(10) :
	Statements

```
在交互式环境中（如命令行形式）后面要多打一个回车才开始运行

# 阶乘
10!
```py
from math import *
factorial(10)
```

# 输出
## 输出为科学计数法
参考：<https://blog.csdn.net/qq_45434742/article/details/102094577?fps=1&locationNum=2>

```py
print("%e" %111)
x = 111
print("%e" %x)
print("%e" %(111 + 111))
```

## 不打印换行符

```py
print('hello', end='')
```

# 其他
[numpy矩阵操作](https://blog.csdn.net/qq_41961459/article/details/119832031)
[Python assert 断言函数](https://www.cnblogs.com/hezhiyao/p/7805278.html)
[Python ASCII码与字符的相互转换](https://blog.csdn.net/beautiful77moon/article/details/88873261)
[vim 空格转tab，2空格缩进转4空格](https://blog.csdn.net/windeal3203/article/details/67638038)
