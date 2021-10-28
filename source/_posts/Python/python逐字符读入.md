---
title: python逐字符读入
date: 2020-02-06 20:44:09
---

参考网站：
https://stackoverflow.com/questions/510357/python-read-a-single-character-from-the-user
https://stackoverflow.com/questions/2988211/how-to-read-a-single-character-at-a-time-from-a-file-in-python

从stdin中逐字符读入：
```py
sys.stdin.read(1)
```
从文件中逐字符读入：
```py
f = open('test.txt')
a = f.read(1)
```

例子：
echo程序
从stdin读入：
```py
import sys
if __name__ == '__main__':
	a = sys.stdin.read(1)
	while a:
		print(a, end="")
		a = sys.stdin.read(1)
```
从test.txt读入：
```py
import sys
if __name__ == '__main__':
	f = open('test.txt')
	a = f.read(1)
	while a:
		print(a, end="")
		a = f.read(1)
```
