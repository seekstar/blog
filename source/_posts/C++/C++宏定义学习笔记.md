---
title: C++宏定义学习笔记
date: 2019-07-14 18:39:46
tags: 学习笔记
---

参考：<https://blog.csdn.net/shuzfan/article/details/52860664>

# 基本语法
```c
#if CONDITION1
...
#elif CONDITION2
...
#else
...
#endif
```

# 多行宏定义
```cpp
#define func(x, y) {	\
	statement;			\
	statement;			\
}
```

# 把宏定义参数变成字符串
```cpp
#define ToStr(x) #x
```
相当于给x加上双引号。

可用于debug时打印变量名
```cpp
#if DEBUG
#include <iostream>
#define debug(x) {cout << #x" = " << x << endl;}
#else
#define debug(x) {}
#endif
```

# 把宏定义参数变成字符
```cpp
#define ToChar(arg) #@arg
```
相当于给arg加上单引号。

# 可变宏参数
```c
#define p(...) printf("%s", #__VA_ARGS__)
```
效果：
```c
p(fasd, 123);
```
输出：
```
fasd, 123
```

# 把宏定义参数连接起来
```cpp
#define connect(x, y) x ## y
```
则connect(abc, def)相当于abcdef。

例子：
```cpp
#include <iostream>

using namespace std;

#define test1 1
#define test2 2

#define test(x) (test ## x)

int main() {
	cout << test(1) << endl << test(2) << endl;

	return 0;
}
```
输出：
```
1
2
```

## 重要性质
如果`x`和`y`里有一个为空，则`x ## y`为空。

# #ifdef的与或
参考：<https://cloud.tencent.com/developer/ask/72838>
```c
#if (defined(MACRO1) || defined(MACRO2)) && (defined(MACRO3) && defined(MACRO4))
```

# 应用：宏定义实现debug语句
DeBuG Print
```c
#define dbgp(fmt, ...) printf("DEBUG: " fmt "\n", ##__VA_ARGS__)
```
如果可变参数个数为0，则`__VA_ARGS__`为空，所以`,##__VA_ARGS__`也为空。这样前面的逗号就被消掉了，不对造成编译错误。
用法：
```c
dbgp("test = %d", 13);
dbgp("test");
```
输出：
```
DEBUG: test = 13
DEBUG: test
```
# 常用预定义宏名
`__LINE__`: 当前行在当前源文件所处的行数。是一个数字。
`__FILE__`: 当前源文件名。是一个字符串。
`__FUNCTION__`: 当前的函数名称。是一个字符串。

可用于打印调试信息。
```c
#define dbgwarn(msg) {	\
	if (DEBUG)	\
		printf("In file " __FILE__ ", line %d, warning: " msg "\n", __LINE__);	\
}
```
用法：
```c
dbgwarn("2333");
```
输出：
```
In file test.c, line 11, warning: 2333
```
