---
title: AddressSanitizer使用教程
date: 2024-11-13 22:42:00
tags:
---

如果遇到了segmentation fault，可以试试AddressSanitizer (aka ASan)。官方文档：<https://github.com/google/sanitizers/wiki/AddressSanitizer>

一般只需要在编译选项中加入`-fsanitize=address`即可。注意，仅在Debug模式下有效。

如果报这个错：

```text
==1803867==ASan runtime does not come first in initial library list; you should either link runtime to your application or manually preload it with LD_PRELOAD.
```

需要在运行的命令前加上（具体的路径可能不一样）：

```shell
LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libasan.so.8
```

如果想要在ASan error的时候dump core，需要在运行命令前：

```shell
# https://stackoverflow.com/questions/42851670/how-to-generate-core-dump-on-addresssanitizer-error
export ASAN_OPTIONS=abort_on_error=1
```
