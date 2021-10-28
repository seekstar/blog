---
title: C语言编译时判断操作系统
date: 2020-04-08 21:52:52
---

参考：<https://sourceforge.net/p/predef/wiki/OperatingSystems/>

```c
#include <stdio.h>

int main() {
#if defined(_WIN16) || defined(_WIN32) || defined(_WIN64)
	printf("windows");
#elif defined(__linux__)
	printf("linux");
#elif defined(__APPLE__)
	printf("apple");
#else
	printf("other");
#endif

	return 0;
}
```
