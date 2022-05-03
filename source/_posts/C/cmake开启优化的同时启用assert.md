---
title: cmake开启优化的同时启用assert
date: 2022-05-03 15:51:26
tags:
---

cmake在将`CMAKE_BUILD_TYPE`设置成`Release`、`RelWithDebInfo`、`MinSizeRel`时，都会加上`-DNDEBUG`选项，将`assert`给优化掉。`Debug`虽然启用了`assert`，但是又没有开优化。

如果需要在开启优化的同时启用`assert`，可以将`CMAKE_BUILD_TYPE`设置成`None`（因为有些project会设置默认`CMAKE_BUILD_TYPE`），然后另外传入编译选项，C语言的编译选项通过设置`CMAKE_C_FLAGS`传入，C++的编译选项通过设置`CMAKE_CXX_FLAGS`传入，两者可以一起设置：

```shell
cmake .. -DCMAKE_BUILD_TYPE=None -DCMAKE_C_FLAGS="-Wall -O3" -DCMAKE_CXX_FLAGS="-Wall -O3"
```

参考：<https://cmake.org/cmake/help/latest/variable/CMAKE_BUILD_TYPE.html>
