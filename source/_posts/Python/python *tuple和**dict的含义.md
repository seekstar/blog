---
title: python *tuple和**dict的含义
date: 2020-12-03 15:27:01
---

原文：<https://stackoverflow.com/questions/21809112/what-does-tuple-and-dict-mean-in-python>

*tuple可以理解为把tuple的内容展开
```py
def foo(x, y):
    print(x, y)

>>> t = (1, 2)
>>> foo(*t)
1 2
```
**dict可以理解为以key=value的方式展开
```py
def foo(x, y):
    print(x, y)

>>> d = {'x':1, 'y':2}
>>> foo(**d)
1 2
```
