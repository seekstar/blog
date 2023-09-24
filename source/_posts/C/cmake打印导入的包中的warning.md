---
title: cmake打印导入的包中的warning
date: 2023-09-24 17:08:46
tags:
---

CMake默认会将imported targets当作system target，这些target提供的头文件路径在编译的时候会用`isystem`来提供，编译器在这些头文件中不会报warning。

但是如果导入的包是我们自己写的，那我们可能会想要打印这些包里的warning。这可以通过`set(CMAKE_NO_SYSTEM_FROM_IMPORTED TRUE)`实现，它会在全局禁止将imported targets当作system target。

`CMAKE_NO_SYSTEM_FROM_IMPORTED`的文档：<https://cmake.org/cmake/help/latest/prop_tgt/NO_SYSTEM_FROM_IMPORTED.html>

参考：

<https://stackoverflow.com/a/5801839/13688160>

<https://github.com/conan-io/conan/issues/269>

<https://github.com/conan-io/conan/issues/1318#issuecomment-303525802>

不过这里面提到的`NO_SYSTEM_FROM_IMPORTED`是consuming target（比如main）的property：<https://gitlab.kitware.com/cmake/cmake/-/issues/17348>

本来`IMPORTED_NO_SYSTEM`应该可以用来避免特定imported target被视为system target，但是我试了这些：

`set_target_properties(依赖1 PROPERTIES IMPORTED_NO_SYSTEM 1)`

`set_property(TARGET 依赖1 PROPERTY IMPORTED_NO_SYSTEM 1)`

不知道为什么都不起作用。。

文档：<https://cmake.org/cmake/help/latest/prop_tgt/IMPORTED_NO_SYSTEM.html>

参考：

<https://gitlab.kitware.com/cmake/cmake/-/issues/17364>

<https://gitlab.kitware.com/cmake/cmake/-/merge_requests/6627>

`IMPORTED_NO_SYSTEM`在3.25被deprecated了，原本的功能被`SYSTEM`取代了：<https://cmake.org/cmake/help/latest/prop_tgt/SYSTEM.html#prop_tgt:SYSTEM>

也没搞懂怎么用。。。

CMake的文档没有例子是真的垃圾（
