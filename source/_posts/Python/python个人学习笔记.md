---
title: python个人学习笔记
date: 2020-03-22 00:16:52
---

## 官方文档

<https://numpy.org/doc/stable/>

## for循环

0到9循环：

```py
for i in range(10) :
	Statements

```

在交互式环境中（如命令行形式）后面要多打一个回车才开始运行

## 阶乘

10!

```py
from math import *
factorial(10)
```

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

## 其他

<!-- Without "-", the two post_link will be in the same line -->

- {% post_link Python/'python常用输入方式' %}

- {% post_link Python/'numpy矩阵操作' %}

- {% post_link Python/'python文件管理' %}

- [Python assert 断言函数](https://www.cnblogs.com/hezhiyao/p/7805278.html)

- [Python ASCII码与字符的相互转换](https://blog.csdn.net/beautiful77moon/article/details/88873261)

- [vim 空格转tab，2空格缩进转4空格](https://blog.csdn.net/windeal3203/article/details/67638038)

- [判断python变量是否存在？](https://www.pynote.net/archives/1681)

- [[Python教学]Python Dictionary完全教学一次搞懂](https://baijiahao.baidu.com/s?id=1694102996150591628&wfr=spider&for=pc)

- [Python中Tuple（元组）](https://blog.csdn.net/wsq119/article/details/105385142)

- [Python 3 命令行参数](https://www.twle.cn/l/yufei/python30/python-30-command-line-arguments.html)

- [Python3 函数](https://www.runoob.com/python3/python3-function.html)

- [python如何修改全局变量](https://blog.csdn.net/yytasty/article/details/115675322)

正则：<https://docs.python.org/3/library/re.html>

字符串trim: <https://www.freecodecamp.org/news/python-strip-how-to-trim-a-string-or-line/>
