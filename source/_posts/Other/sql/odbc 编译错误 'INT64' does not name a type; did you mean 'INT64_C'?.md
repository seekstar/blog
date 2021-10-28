---
title: odbc 编译错误 'INT64' does not name a type; did you mean 'INT64_C'?
date: 2020-04-08 22:51:59
---

在windows下sqlext.h依赖于windows.h。
```cpp
#if defined(_WIN16) || defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#endif
#include <sqlext.h>
```
