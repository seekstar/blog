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
