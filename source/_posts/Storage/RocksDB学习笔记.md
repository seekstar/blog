---
title: RocksDB学习笔记
date: 2023-07-28 13:52:54
tags:
---

Version是在某个瞬间各种SSTable的snapshot。

SuperVersion是最新的Version加上

- memory table
- immutable memory table。
- Mutable options

Get的时候如果不是在snapshot上get，那么先拿thread local的SuperVersion，再在上面Get。在`ColumnFamilyData::InstallSuperVersion`中会更新thread local SuperVersion。

在hold DB mutex的情况下，可以直接调用`ColumnFamilyData::GetSuperVersion`拿最新的SuperVersion。
