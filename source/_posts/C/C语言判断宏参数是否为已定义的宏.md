---
title: C语言判断宏参数是否为已定义的宏
date: 2021-11-27 14:50:44
tags:
---

在宏定义中不能使用`#ifdef`来判断另一个宏是否被定义。那么怎么实现下面的功能呢？

```
// 为了可读性，把末尾的转义字符省略了。
#define MY_MACRO(flag, var) do {
    // Many operations
    #ifdef flag
        // Do something
    #endif
    // Many operations
} while (0)
```

这要用到C语言对宏参数的处理方式。如果宏参数是另一个宏的名字，那么就将这个宏参数展开成那个宏。特别地，如果要对这个宏参数用`#`变成字符串，那就直接把这个宏的名字转成字符串。考虑下面的代码：

```c
#define STRINGIFY(x) #x

#define CHECK2(name) do { \
	puts(#name); \
	puts(STRINGIFY(name)); \
} while (0)
```

`puts(#name)`是直接将`name`变成其代表的字符串。但是假如`name`是一个已定义宏，那在将`name`传入到`STRINGIFY`里面前，会先将`name`展开，然后`STRINGIFY`里就是将展开后的`name`转成字符串。

举个例子：

```c
#define TEST1_DISABLED 1
CHECK2(TEST1_DISABLED);
```

输出为

```
TEST1_DISABLED
1
```

利用这个差别就可以判断宏参数是否为已定义宏。假如宏名字的长度大于1，且宏如果被定义的话，一定被定义为1，那么可以这样判断这个宏是否被定义：

```c
#define CHECK(name) (sizeof STRINGIFY(name) == 2)
```

其实还可以这样判断：

```c
#define CHECK(name) (#name [0] != STRINGIFY(name) [0])
```

但是这样的话，这个`CHECK`就不能在`_Static_assert`里用。

这个宏可以在其他宏里用：

```c
#define TEST1_DISABLED 1
#define IS_DISABLED(name) CHECK(name ## _DISABLED)
printf("%d\n", IS_DISABLED(TEST1));
printf("%d\n", IS_DISABLED(TEST3));
```

输出：

```
1
0
```

思路来源：<https://stackoverflow.com/questions/47491147/check-at-runtime-if-macro-was-defined?rq=1>

完整代码：

```c
#include <stdio.h>

#define TEST1_DISABLED 1

#define STRINGIFY(x) #x

#define CHECK2(name) do { \
	puts(#name); \
	puts(STRINGIFY(name)); \
} while (0)

//#define CHECK(name) (#name [0] != STRINGIFY(name) [0])
#define CHECK(name) (sizeof STRINGIFY(name) == 2)

#define IS_DISABLED(name) CHECK(name ## _DISABLED)

#define TEST2_DISABLED 1

int main() {
	CHECK2(TEST1_DISABLED);
	putchar('\n');
	CHECK2(TEST2_DISABLED);
	putchar('\n');
	CHECK2(TEST3_DISABLED);
	putchar('\n');

	printf("%d\n", IS_DISABLED(TEST1));
	printf("%d\n", IS_DISABLED(TEST2));
	printf("%d\n", IS_DISABLED(TEST3));

	return 0;
}
```
