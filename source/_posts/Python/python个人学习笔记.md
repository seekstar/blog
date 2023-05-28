---
title: python个人学习笔记
date: 2020-03-22 00:16:52
---

## 语法

- [Python if 语句](https://m.runoob.com/python3/python3-if-example.html)

- [Python3 函数](https://www.runoob.com/python3/python3-function.html)

- [python之generator详解](https://blog.csdn.net/zhong_jay/article/details/91799459)

- [python如何修改全局变量](https://blog.csdn.net/yytasty/article/details/115675322)

- [Python assert 断言函数](https://www.cnblogs.com/hezhiyao/p/7805278.html)

- [判断python变量是否存在？](https://www.pynote.net/archives/1681)

- [Python ASCII码与字符的相互转换](https://blog.csdn.net/beautiful77moon/article/details/88873261)

### for循环

0到9循环：

```py
for i in range(10) :
	Statements

```

在交互式环境中（如命令行形式）后面要多打一个回车才开始运行

## 类

```py
from dataclasses import dataclass
@dataclass
class A:
    a: int
    b: str
    c: float
li: list[A] = []
li.append(A(1, "2", 3.3))
li.append(A(2, "3", 4.4))
print(li)
# [<class '__main__.A'>, A(a=1, b='2', c=3.3), A(a=2, b='3', c=4.4)]
item = li[1]
print(item.c)
# 3.3
sorted(li, key = lambda item: item.c, reverse=True)
```

参考：<https://stackoverflow.com/questions/35988/c-like-structures-in-python>

完整教程：[Python 面向对象](https://www.runoob.com/python/python-object.html)

## 内置数据结构

- [Python教学: Python Dictionary完全教学一次搞懂](https://baijiahao.baidu.com/s?id=1694102996150591628&wfr=spider&for=pc)

- [Python 列表(List)](https://www.runoob.com/python/python-lists.html)

- [Python中Tuple（元组）](https://blog.csdn.net/wsq119/article/details/105385142)

## 输入

- {% post_link Python/'python常用输入方式' %}

## 输出

完整版：[Python3 print 函数用法总结](https://www.runoob.com/w3cnote/python3-print-func-b.html)

### 输出为科学计数法

参考：<https://blog.csdn.net/qq_45434742/article/details/102094577?fps=1&locationNum=2>

```py
print("%e" %111)
x = 111
print("%e" %x)
print("%e" %(111 + 111))
print("%e %e" %(x, 111 + 111))
```

### 不打印换行符

```py
print('hello', end='')
```

### 打印到stderr

```py
print('xxx', file=sys.stderr)
```

来源：<https://stackoverflow.com/questions/5574702/how-do-i-print-to-stderr-in-python>

### 指定分隔符打印数组

```py
>>> L = [1, 2, 3, 4, 5]
>>> print(*L)
1 2 3 4 5
>>> print(*L, sep=', ')
1, 2, 3, 4, 5
>>> print(*L, sep=' -> ')
1 -> 2 -> 3 -> 4 -> 5
```

来源：<https://stackoverflow.com/questions/22556449/print-a-list-of-space-separated-elements>

## 文件

{% post_link Python/'python文件管理' %}

[python基础之写文件操作](https://blog.csdn.net/jiankang66/article/details/125981793)

## 排序

用`sorted`。

### 对字典的key排序

```py
x = {1: 2, 4: 3, 2: 1}
sorted(x)
```

```text
[1, 2, 4]
```

### 对字典的值排序

```py
x = {1: 2, 3: 4, 4: 3, 2: 1, 0: 0}
sorted(x.items(), key=lambda item: item[1])
```

```text
[(0, 0), (2, 1), (1, 2), (4, 3), (3, 4)]
```

来源：<https://stackoverflow.com/questions/613183/how-do-i-sort-a-dictionary-by-value>

## 标准库

### 时间

<https://docs.python.org/3/library/datetime.html>

```py
datetime.datetime.fromtimestamp(1516332287)
```

也可以用`time`包：[Python中时间与时间戳之间的转换](https://blog.csdn.net/google19890102/article/details/51355282)

### math

#### 阶乘

10!

```py
from math import *
factorial(10)
```

### 正则

<https://docs.python.org/3/library/re.html>

### 其他

- [Python 3 命令行参数](https://www.twle.cn/l/yufei/python30/python-30-command-line-arguments.html)

- 获取命令输出：[python的popen函数](https://blog.csdn.net/Z_Stand/article/details/89375589)

- [python 生成随机数的三种方法](https://blog.csdn.net/robert_chen1988/article/details/82887820)

- Waiting for I/O completion: <https://docs.python.org/3/library/select.html>

- 字符串trim: <https://www.freecodecamp.org/news/python-strip-how-to-trim-a-string-or-line/>

- [with statement in Python](https://www.geeksforgeeks.org/with-statement-in-python/)

## 三方库

### dateutil

<https://dateutil.readthedocs.io/en/stable/>

```shell
pip3 install python-dateutil
```

可以实现时间减去月数等功能。

来源：<https://thispointer.com/subtract-months-from-a-date-in-python/>

### pandas

官方文档：<https://pandas.pydata.org/docs/>

{% post_link Python/'pandas数据框常用操作' %}

### numpy

官方文档：<https://numpy.org/doc/stable/>

#### 矩阵操作

- {% post_link Python/'numpy矩阵操作' %}

#### 等差数列

文档：<https://numpy.org/doc/stable/reference/generated/numpy.linspace.html>

```py
numpy.linspace(start, stop, num=50, endpoint=True, retstep=False, dtype=None, axis=0)[source]
```

### 其他

- [python字典和JSON格式的转换](https://blog.csdn.net/sinat_36899414/article/details/77817195)

`json.dumps(obj, indent='\t')`可以使用tab进行缩进。

## pip

安装指定版本：<https://www.marsja.se/pip-install-specific-version-of-python-package/>

requirements.txt: <https://note.nkmk.me/en/python-pip-install-requirements/>

## 有关

- [vim 空格转tab，2空格缩进转4空格](https://blog.csdn.net/windeal3203/article/details/67638038)
