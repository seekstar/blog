---
title: 编译RocksDB
date: 2022-04-21 19:59:17
tags: RocksDB
---

## make

静态库：

```shell
make -j shared_lib
```

动态库：

```shell
make -j static_lib
```

但是这俩好像只能用一个，在编译另一个之前好像要先`make clean`一下。相关：{% post_link Storage/'rocksdb-usr-bin-ld-memory-concurrent-arena-o-relocation-R-X86-64-TPOFF32-against-symbol-ZN7rocksdb15C' %}

## cmake

```shell
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DUSE_RTTI=true
```

`-DUSE_RTTI=true`是开启反射。相关：{% post_link Storage/'undefined-reference-to-typeinfo-for-rocksdb-Customizable' %}

```shell
# 全部编译
make -j
# 只编译静态库
make -j librocksdb.a
# 只编译动态库
make -j rocksdb-shared
```
