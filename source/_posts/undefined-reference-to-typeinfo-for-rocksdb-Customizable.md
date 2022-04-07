---
title: 'undefined reference to typeinfo for rocksdb::Customizable'
date: 2022-04-07 20:35:21
tags: RocksDB
---

如果是用的cmake编译，要在cmake的参数里加上`-DUSE_RTTI=true`。

来源：

<https://groups.google.com/g/rocksdb/c/ODArfKT61XE>
