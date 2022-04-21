---
title: RocksDB单元测试
date: 2022-04-21 17:06:49
tags: RocksDB
---

```shell
make all check
```

可以加上`-j 线程数`来做并行单元测试。

如果出错了，看下出错的是哪个测试，比如假如是`DBBasicTest.OpenWhenOpen`，那这个测试就在`db_basic_test`，单独运行这个测试：

```shell
./db_basic_test --gtest_filter="*DBBasicTest.OpenWhenOpen*"
```

原文：<https://www.bookstack.cn/read/rocksdb-en/458d285f9fcf34ac.md>
