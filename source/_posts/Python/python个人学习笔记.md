---
title: python个人学习笔记
date: 2020-03-22 00:16:52
---

## 语法

缩进应该使用4个空格而不是tab：<https://peps.python.org/pep-0008/#tabs-or-spaces>

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

## 内置数据结构

### List

教程：[Python 列表(List)](https://www.runoob.com/python/python-lists.html)

```python
a = [1, 2, 3, 4]

# 最后一个元素
# 4
a[-1]

# 从index为1的元素开始的所有元素
# [2, 3, 4]
a[1:]

# 以最后一个元素结尾（不含）的所有元素
# [1, 2, 3]
a[:-1]

# 以倒数第二个元素结尾（不含）的所有元素
# [1, 2]
a[:-2]
```

### 字典

[Python教学: Python Dictionary完全教学一次搞懂](https://baijiahao.baidu.com/s?id=1694102996150591628&wfr=spider&for=pc)

#### 遍历

```py
likes = {"color": "blue", "fruit": "apple", "pet": "dog"}
for key in likes:
    print(key)
```

输出：

```text
color
fruit
pet
```

```py
for (key, value) in likes.items():
    print(key, value)
```

输出：

```text
color blue
fruit apple
pet dog
```

来源：<https://realpython.com/iterate-through-dictionary-python/>

### 其他

- [Python中Tuple（元组）](https://blog.csdn.net/wsq119/article/details/105385142)

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

## format

打印到字符串。完整教程：<https://note.nkmk.me/en/python-format-zero-hex/>

这里介绍一些常用的。

保留3位小数：`assert '{:.3f}'.format(2.3) == '2.300'`

## iterator

遍历：

```py
it = iter([1, 2, 3])
while True:
    try:
        print(next(it))
    except StopIteration:
        break
```

`for`循环会自动catch `StopIteration`:

```py
it = iter([1, 2, 3])
for x in it:
    print(x)
```

## 文件

{% post_link Python/'python文件管理' %}

[python基础之写文件操作](https://blog.csdn.net/jiankang66/article/details/125981793)

### 切换到脚本所在目录

```py
import sys
import os

abspath = os.path.abspath(sys.argv[0])
dname = os.path.dirname(abspath)
os.chdir(dname)
```

来源：<https://stackoverflow.com/questions/1432924/python-change-the-scripts-working-directory-to-the-scripts-own-directory>

### 打印到文件

使用`print`的`file`参数：

```py
f = open(路径, 'w')
print('Average %f' %average, file=f)
```

来源：<https://www.askpython.com/python/built-in-methods/python-print-to-file>

## Exceptions

Built-in Exceptions: <https://docs.python.org/3/library/exceptions.html>

常用的：

- [FileNotFoundError](https://docs.python.org/3/library/exceptions.html#FileNotFoundError)

## 标准库

### `io`

<https://stackoverflow.com/questions/39823303/python3-print-to-string>

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

### 执行命令

#### 简单执行命令

```py
os.system('命令 参数...')
```

返回值是OS-dependant：<https://stackoverflow.com/questions/6466711/what-is-the-return-value-of-os-system-in-python>

可以用[os.waitstatus_to_exitcode](https://docs.python.org/3/library/os.html#os.waitstatus_to_exitcode)来将返回值变成exit code。如果正常退出，exit code就是0。

#### 带参数命令

```py
import subprocess
subprocess.call(['./executable', arg1, arg2])
```

来源：<https://stackoverflow.com/questions/5788891/execute-a-file-with-arguments-in-python-shell>

#### 获取命令输出

[python的popen函数](https://blog.csdn.net/Z_Stand/article/details/89375589)

### 排序

用`sorted`。

#### 对字典的key排序

```py
x = {1: 2, 4: 3, 2: 1}
sorted(x)
```

```text
[1, 2, 4]
```

#### 对字典的值排序

```py
x = {1: 2, 3: 4, 4: 3, 2: 1, 0: 0}
sorted(x.items(), key=lambda item: item[1])
```

```text
[(0, 0), (2, 1), (1, 2), (4, 3), (3, 4)]
```

来源：<https://stackoverflow.com/questions/613183/how-do-i-sort-a-dictionary-by-value>

### shlex

可以用解析命令行参数的方式解析字符串。文档：<https://docs.python.org/3/library/shlex.html>

例子：

```py
# https://stackoverflow.com/a/899314
import shlex
shlex.split('-o 1 --long "Some long string"')
```

```text
['-o', '1', '--long', 'Some long string']
```

### `getopt`

用法跟C语言的`getopt`差不多。

参考：[Python 3 命令行参数](https://www.twle.cn/l/yufei/python30/python-30-command-line-arguments.html)

### 取整

四舍五入：`round`

向上取整：`math.ceil`

向下取整：`math.floor`

### 其他

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

#### Serias

官方文档：<https://pandas.pydata.org/docs/reference/api/pandas.Series.html>

常用成员函数

取平均：<https://pandas.pydata.org/docs/reference/api/pandas.Series.mean.html>

### numpy

{% post_link Python/'numpy学习笔记' %}

### json

#### 字典和json字符串的转换

- [python字典和JSON格式的转换](https://blog.csdn.net/sinat_36899414/article/details/77817195)

```py
import json
# 使用tab进行缩进。
json.dumps(obj, indent='\t')
```

#### 从文件读取

```py
import json
json.load(open(路径))
```

但是遇到trailing comma会报错。可以用json5: <https://stackoverflow.com/questions/23705304/can-json-loads-ignore-trailing-commas>

```shell
pip3 install json5
```

```py
import json5
json5.load(open(路径))
```

## pip

安装指定版本：<https://www.marsja.se/pip-install-specific-version-of-python-package/>

requirements.txt: <https://note.nkmk.me/en/python-pip-install-requirements/>

## 有关

- [vim 空格转tab，2空格缩进转4空格](https://blog.csdn.net/windeal3203/article/details/67638038)

## 已知的问题

调用另一个文件里的函数不太方便: <https://www.geeksforgeeks.org/python-import-module-from-different-directory/>
