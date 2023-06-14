---
title: python常用输入方式
date: 2021-07-22 12:46:16
---

## 逐字符读入

## 逐行读入

### stdin

```py
import sys
for line in sys.stdin:
	# 去掉末尾换行符
	line = line.strip()
    print(line)
```

参考

<https://blog.csdn.net/qq_41961459/article/details/104201928>

<https://stackoverflow.com/questions/1450393/how-do-you-read-from-stdin>

### 文件

把上面的`sys.stdin`换成`open('path/to/file')`：

```py
for line in open('/path/to/file'):
	# 去掉末尾换行符
	line = line.strip()
	print(line)
```

参考：<https://www.cnblogs.com/sysuoyj/archive/2012/03/14/2395789.html>

## 一次性读取并按行保存为list

不保留每行末尾的换行符：

```py
f.read().splitlines()
```

参考：<https://stackoverflow.com/questions/3925614/how-do-you-read-a-file-into-a-list-in-python>

保留每行末尾的换行符：

```py
f.readlines()
```

来源：<https://docs.python.org/3/tutorial/inputoutput.html>

读取为整型：

```py
[int(line) for line in open('hits_cdf')]
```

参考：<https://stackoverflow.com/questions/6583573/how-to-read-numbers-from-file-in-python>

## 读取参数

`sys.argv`: 参数列表。`sys.argv[0]`一般是当前命令。

`len(sys.argv)`是参数个数。
