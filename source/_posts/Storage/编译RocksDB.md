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
cmake .. -DCMAKE_BUILD_TYPE=Release -DUSE_RTTI=true -DFAIL_ON_WARNINGS=OFF
# 全部编译
make -j$(nproc)
# 只编译静态库
make -j$(nproc) rocksdb
# 只编译动态库
make -j$(nproc) rocksdb-shared
```

`-DUSE_RTTI=true`中`RTTI`的全称是`Run-Time Type Identification`。相关：

{% post_link Storage/'undefined-reference-to-typeinfo-for-rocksdb-Customizable' %}

[C++ RTTI 实现原理详解](https://blog.csdn.net/xiangbaohui/article/details/109231333)

### Asynchronous IO

官方文档：<https://github.com/facebook/rocksdb/wiki/Asynchronous-IO>

先编译安装folly: {% post_link Storage/'编译folly' %}

这里假设folly安装到了`$workspace/deps`。

```shell
sudo apt install -y liburing-dev

cd build
# -DPORTABLE=ON: 因为folly编译的时候没有-march=native，所以rocksdb编译的时候也不要-march-native
# -DWITH_LIBURING=OFF: 不知道为什么，如果WITH_LIBURING=ON，db_bench执行完成之后reader不知道为什么会卡住没法返回
cmake .. -DCMAKE_BUILD_TYPE=Release -DUSE_RTTI=true -DFAIL_ON_WARNINGS=OFF -DUSE_COROUTINES=true -DROCKSDB_BUILD_SHARED=OFF -DPORTABLE=ON -DWITH_LIBURING=OFF
make -j$(nproc)
```

然后就可以在`ReadOptions`里开`async_io`了。
