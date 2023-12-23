---
title: C语言个人学习笔记
date: 2020-03-22 14:32:18
---

## 宏

{% post_link C/'C语言判断宏参数是否为已定义的宏' %}

### 返回值

被`({`和`})`包起来的语句中，最后一个语句的值就是整个语句的值。可以用这个特性来构造有返回值的宏。例子：

```c
#include <stdio.h>
#include <assert.h>

#define test23(choice) ({	\
	int ret;				\
	if (choice) {			\
		ret = 2;			\
	} else {				\
		ret = 3;			\
	}						\
	ret;					\
})

int main() {
	assert(test23(0) == 3);
	assert(test23(1) == 2);

	return 0;
}
```

参考：<https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html>

## builtin系列

参考：
<https://www.cnblogs.com/liuzhanshan/p/6861596.html>
<https://blog.csdn.net/weixin_40676873/article/details/85239890>

这一系列不带后缀表示参数是unsigned int，例如`__builtin_ctz`，带后缀`l`表示参数是long，例如`__builtin_ctzl`，带后缀`ll`表示参数是long long，例如`__builtin_ctzll`。

| 函数 | 功能 | 备注 |
| ---- | ---- | ---- |
| __builtin_ctz | 后面的0的个数，参数为0时结果未定义 | Count Trailing Zero |
| __builtin_clz | x前导0的个数，参数为0时结果未定义 | Count Leading Zero |
| __builtin_popcount | 1的个数 | [population count](<https://www.cnblogs.com/Martinium/archive/2013/03/01/popcount.html>) |

## 格式控制符

| 符号 | 含义 |
| ---- | ---- |
| `%d` | int |
| `%ld` | long |
| `%lld` | long long |
| `%zd` | ssize_t |
| `%u` | unsigned int |
| `%lu` | unsigned long |
| `%llu` | unsigned long long |
| `%zu` | size_t |

十六进制把`u`换成`x`，例如`%zx`用十六进制打印`size_t`。

## 取整

| 目标 | 方法 |
| ---- | ---- |
| 向下取整 | floor(x) |
| 向上取整 | ceil(x) |
| 向零取整 | (int)x |

整数除法是向零取整，这是因为负数模正数的结果是非正数。
右移是向下取整。

## float常量

在小数后面加`f`即可，例如`1.0f`。
但是不能是`1f`，因为`1`是整型。

## 常用库函数

### string.h

#### memccpy

```c
void * memccpy(void *dest, const void * src, int c, size_t n);
```

拷贝src 所指的内存内容前n 个字节到dest 所指的地址上，直到发现某一个字节的值与c相等，然后返回指向相等的字节的后一个字节的指针。如果没有相等的字节，就返回NULL。

## 创建临时目录

用`mkdtemp`，文档：<https://linux.die.net/man/3/mkdtemp>

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
	char template[] = "/tmp/test-XXXXXX";
	char *fname = mkdtemp(template);
	if (fname == NULL) {
		perror("mkdtemp");
		return 1;
	}
	puts(fname);

	return 0;
}
```

## 执行命令并获取输出

用`popen`: <https://man7.org/linux/man-pages/man3/popen.3.html>

用完记得用`pclose`关掉。

```c
FILE *pipe = popen(command, "r");
if (pipe == NULL) {
	perror("popen");
	abort();
}
// Read pipe
if (-1 == pclose(pipe)) {
	perror("pclose");
	abort();
}
```

参考：<https://stackoverflow.com/questions/478898/how-do-i-execute-a-command-and-get-the-output-of-the-command-within-c-using-po>
