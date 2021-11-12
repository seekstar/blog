---
title: boost::system::error_code赋值
date: 2020-04-25 16:57:05
tags:
---

参考：<https://theboostcpplibraries.com/boost.system>

```cpp
boost::system::error_code error = boost::system::errc::make_error_code(boost::system::errc::success)
```
