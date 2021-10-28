---
title: C语言个人学习笔记
date: 2020-03-22 14:32:18
---

# builtin系列
参考：
<https://www.cnblogs.com/liuzhanshan/p/6861596.html>
<https://blog.csdn.net/weixin_40676873/article/details/85239890>

这一系列不带后缀表示参数是unsigned int，例如```__builtin_ctz```，带后缀```l```表示参数是long，例如```__builtin_ctzl```，带后缀```ll```表示参数是long long，例如```__builtin_ctzll```。

| 函数 | 功能 | 备注 |
| ---- | ---- | ---- |
| __builtin_ctz | 后面的0的个数，参数为0时结果未定义 | Count Trailing Zero |
| __builtin_clz | x前导0的个数，参数为0时结果未定义 | Count Leading Zero |
| __builtin_popcount | 1的个数 | [population count](<https://www.cnblogs.com/Martinium/archive/2013/03/01/popcount.html>) |

# 取整
| 目标 | 方法 |
| ---- | ---- |
| 向下取整 | floor(x) |
| 向上取整 | ceil(x) |
| 向零取整 | (int)x |

整数除法是向零取整，这是因为负数模正数的结果是非正数。
右移是向下取整。

# float常量
在小数后面加```f```即可，例如```1.0f```。
但是不能是```1f```，因为```1```是整型。

# 常用库函数
## string.h
### memccpy
```c
void * memccpy(void *dest, const void * src, int c, size_t n);
```
拷贝src 所指的内存内容前n 个字节到dest 所指的地址上，直到发现某一个字节的值与c相等，然后返回指向相等的字节的后一个字节的指针。如果没有相等的字节，就返回NULL。
