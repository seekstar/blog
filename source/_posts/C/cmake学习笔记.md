---
title: cmake学习笔记
date: 2023-03-14 15:02:15
tags:
---

- {% post_link C/'cmake开启优化的同时启用assert' %}

- {% post_link C/'cmake设置默认CMAKE_BUILD_TYPE' %}

- {% post_link 'C++/cmake使用cpp-17' %}

## 传入宏定义

```cmake
option(MACRO_NAME
    “Descriptions of the macro”
    OFF)
if (MACRO_NAME)
  add_compile_definitions(MACRO_NAME)
endif ()
```

然后`cmake .. -DMACRO_NAME=ON`，再`make`就好了。

## `find_library`

<https://stackoverflow.com/questions/29657195/how-to-test-if-cmake-found-a-library-with-find-library>

```cmake
find_library(LUA_LIB lua)
if(NOT LUA_LIB)
  message(FATAL_ERROR "lua library not found")
endif()
```

## message

<https://cmake.org/cmake/help/latest/command/message.html>

## PUBLIC, PRIVATE, INTERFACE

[Difference between PRIVATE and PUBLIC with target_link_libraries](https://cmake.org/pipermail/cmake/2016-May/063400.html)

假设A PRIVATE依赖B，A是静态库，B是动态库。如果executable C依赖A的话，cmake会自动把B链接到C上。

## 已知的问题

### 忽略`LD_LIBRARY_PATH`

CMake会忽略`LD_LIBRARY_PATH`。因此把库放进`LD_LIBRARY_PATH`里CMake还是找不到。

不过可以在cmake里读取环境变量`LD_LIBRARY_PATH`：<https://stackoverflow.com/a/49738486/13688160>

然后就可以把它作为`find_package`的参数或者加入到`target_link_directories`里。
