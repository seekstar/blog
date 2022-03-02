---
title: cmake使用C++17
date: 2022-03-02 19:13:50
tags:
---

```cmake
target_compile_features(${TARGET_NAME} PRIVATE cxx_std_17)
```

下面这种方法好像已经没有用了：

```cmake
set(CMAKE_CXX_STANDARD 17)
```

来源：<https://stackoverflow.com/questions/45688522/how-to-enable-c17-in-cmake>
