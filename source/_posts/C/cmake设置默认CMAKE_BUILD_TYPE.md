---
title: cmake设置默认CMAKE_BUILD_TYPE
date: 2021-02-22 17:26:02
---

原文：<https://cmake.org/pipermail/cmake/2009-June/030311.html>

在```CMakeLists.txt```里写入
```
IF (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING
        "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel." FORCE)
ENDIF()
```
