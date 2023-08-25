---
title: CMake find_package兼容add_subdirectory
date: 2023-08-25 17:15:50
tags:
---

如果依赖是通过`add_subdirectory`添加的，那么`find_package`的时候会报错找不到`xxx-config.cmake`。

实际上通过`add_subdirectory`添加的话，对应的target已经存在了。所以我们可以直接判断如果target已经存在就跳过`find_package`:

```cmake
if (NOT TARGET 依赖1)
	find_package(依赖1 CONFIG REQUIRED)
endif()
```

## 参考文献

<https://stackoverflow.com/questions/27339329/how-to-check-whether-a-target-has-been-added-or-not>

`CMake find_package dependency on subproject`: <https://stackoverflow.com/a/64786025>
