---
title: python常用输入方式
date: 2021-07-22 12:46:16
---

# 逐字符读入
<https://blog.csdn.net/qq_41961459/article/details/104201928>

# 逐行读入
文件：<https://www.cnblogs.com/sysuoyj/archive/2012/03/14/2395789.html>

从stdin中逐行读入只需要把上面中的文件换成`sys.stdin`即可。
例子：
```py
import sys
for line in sys.stdin:
	# 去掉末尾换行符
	line = line.strip()
    print(line)
```
参考：<https://stackoverflow.com/questions/1450393/how-do-you-read-from-stdin>

# 读取参数
`sys.argv`: 参数列表。`sys.argv[0]`一般是当前命令。
`len(sys.argv)`是参数个数。
