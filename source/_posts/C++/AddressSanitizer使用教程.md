---
title: AddressSanitizer使用教程
date: 2024-11-13 22:42:00
tags:
---

如果遇到了segmentation fault，可以试试AddressSanitizer (aka ASan)。官方文档：<https://github.com/google/sanitizers/wiki/AddressSanitizer>

一般只需要在编译选项中加入`-fsanitize=address`即可。注意，仅在Debug模式下有效。

如果项目使用cmake的话，可以在`CMakeLists.txt`里加上：

```cmake
option(WITH_ASAN "build with ASAN" OFF)
if(WITH_ASAN)
	add_compile_options(-fsanitize=address)
	# Should come first in initial library list
	target_link_libraries(${PROJECT_NAME} PRIVATE asan)
endif()
```

然后编译的时候在cmake的参数里加上`-DCMAKE_BUILD_TYPE=Debug -DWITH_ASAN=ON`即可。

注意，`target_link_libraries(${PROJECT_NAME} PRIVATE asan)`要出现在其他`target_link_libraries`之前，否则运行的时候会报这个错：

```text
==1803867==ASan runtime does not come first in initial library list; you should either link runtime to your application or manually preload it with LD_PRELOAD.
```

也可以不写`target_link_libraries(${PROJECT_NAME} PRIVATE asan)`，而是在运行的命令前LD_PRELOAD（具体的路径可能不一样）：

```shell
LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libasan.so.8 命令 参数...
```

如果想要在ASan error的时候dump core，需要在运行命令前：

```shell
# https://stackoverflow.com/questions/42851670/how-to-generate-core-dump-on-addresssanitizer-error
export ASAN_OPTIONS=abort_on_error=1
```
