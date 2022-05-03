---
title: 编译RocksDB
date: 2022-04-21 19:59:17
tags: RocksDB
---

## make

静态库：

```shell
make -j$(nproc) static_lib
```

动态库：

```shell
make -j$(nproc) shared_lib
```

但是这俩好像只能用一个，在编译另一个之前好像要先`make clean`一下。相关：{% post_link Storage/'rocksdb-usr-bin-ld-memory-concurrent-arena-o-relocation-R-X86-64-TPOFF32-against-symbol-ZN7rocksdb15C' %}

## cmake

```shell
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DUSE_RTTI=true
# 全部编译
make -j$(nproc)
# 只编译静态库
make -j$(nproc) librocksdb.a
# 只编译动态库
make -j$(nproc) rocksdb-shared
```

`-DUSE_RTTI=true`中`RTTI`的全称是`Run-Time Type Identification`。相关：

{% post_link Storage/'undefined-reference-to-typeinfo-for-rocksdb-Customizable' %}

[C++ RTTI 实现原理详解](https://blog.csdn.net/xiangbaohui/article/details/109231333)
