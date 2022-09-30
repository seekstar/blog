---
title: C++ panic
date: 2022-09-30 21:27:56
tags:
---

```cpp
#define panic(fmt, ...) do { \
	fprintf(stderr, "panic: %s:%u: %s:", \
		__FILE__, __LINE__, __func__); \
	fprintf(stderr, " " fmt, ##__VA_ARGS__);	\
	abort(); \
} while (0)
```

例子：

```cpp
#include <stdio.h>
#include <stdlib.h>

#define panic(fmt, ...) do { \
	fprintf(stderr, "panic: %s:%u: %s:", \
		__FILE__, __LINE__, __func__); \
	fprintf(stderr, " " fmt, ##__VA_ARGS__);	\
	abort(); \
} while (0)

int main() {
	// They all works
	//panic();
	//panic("%d", 233);
	panic("%d != %d", 233, 332);

	return 0;
}
```

```text
panic: panic.cpp:15: main: 233 != 332
```

注意，宏参是可以少给的，其中`panic()`里没给`fmt`，所以宏展开里`fmt`就直接消失，不替换成任何东西。

也可以弄一个类似于`assert`的`crash_if`，不同的是这个`crash_if`不受编译选项的影响：

```cpp
#define crash_if(cond, fmt, ...) do { \
	if (cond) { panic(fmt, ##__VA_ARGS__); }	\
} while (0)

crash_if(233 != 332, "%d != %d", 233, 332);
```

```text
panic: panic.cpp:21: main: 233 != 332
```

## 失败经验：stacktrace

上面的都只是打印了出错点的信息，但是没有打印调用栈。其实可以使用boost打印调用栈：

```cpp
#include <iostream>
#include <boost/stacktrace.hpp>
using namespace std;
int main() {
	std::cout << boost::stacktrace::stacktrace();
	return 0;
}
```

```text
 0# 0x0000560AE9E033AD in ./stacktrace
 1# 0x00007FF75B754290 in /usr/lib/libc.so.6
 2# __libc_start_main in /usr/lib/libc.so.6
 3# 0x0000560AE9E03285 in ./stacktrace
```

可以看到只有文件，没有显示行号。

根据官方文档：<https://www.boost.org/doc/libs/1_80_0/doc/html/stacktrace/configuration_and_build.html>

以及这个：<https://stackoverflow.com/questions/52583544/boost-stack-trace-not-showing-function-names-and-line-numbers>

我试了一下addr2line:

```text
g++ -DBOOST_STACKTRACE_LINK -DBOOST_STACKTRACE_USE_ADDR2LINE -lboost_stacktrace_addr2line -ldl -no-pie -fno-pie -g stacktrace.cpp -o stacktrace
```

但是只是打印了部分函数，仍然没有行号：

```text
 0# boost::stacktrace::basic_stacktrace<std::allocator<boost::stacktrace::frame> >::basic_stacktrace() at /usr/include/boost/stacktrace/stacktrace.hpp:129
 1# 0x00007FA7E2134290 in /usr/lib/libc.so.6
 2# __libc_start_main in /usr/lib/libc.so.6
 3# _start at /build/glibc/src/glibc/csu/../sysdeps/x86_64/start.S:117
```

而`boost_stacktrace_backtrace`在我的ArchLinux上没有。。。

所以就放弃了。

相关：<https://github.com/boostorg/stacktrace/issues/49>
