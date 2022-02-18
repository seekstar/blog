---
title: >-
  rocksdb: /usr/bin/ld: ./memory/concurrent_arena.o: relocation R_X86_64_TPOFF32
  against symbol `_ZN7rocksdb15C
date: 2022-01-01 12:54:31
tags: RocksDB
---

官方的编译教程：<https://github.com/facebook/rocksdb/blob/main/INSTALL.md>

按照上面说的，先编译静态库：

```shell
make static_lib
```

这个正常。但是再编译动态库时：

```shell
make shared_lib
```

会报错：

```
/usr/bin/ld: ./memory/concurrent_arena.o: relocation R_X86_64_TPOFF32 against symbol `_ZN7rocksdb15ConcurrentArena9tls_cpuidE' can not be used when making a shared object; recompile with -fPIC
```

我认为是因为不能同时编译静态库和动态库，因为编译动态库时需要带上这个编译选项：`-fPIC`。所以清理之后再单独编译动态库即可：

```shell
make clean
make shared_lib
```
