---
title: RocksDB学习笔记
date: 2023-07-28 13:52:54
tags: RocksDB
---

Version是在某个瞬间各种SSTable的snapshot。

SuperVersion是最新的Version加上

- memory table
- immutable memory table。
- Mutable options

ColumnFamilyData和SuperVersion互相保存了对方的引用。在`ColumnFamilyData::InstallSuperVersion`中，会先调用`SuperVersion::Init`将SuperVersion的ref变成1，并且让这个SuperVersion引用自己，让自己的引用计数+1。

Get的时候如果不是在snapshot上get，那么先拿thread local的SuperVersion，再在上面Get。在`ColumnFamilyData::InstallSuperVersion`中会更新thread local SuperVersion。

在hold DB mutex的情况下，可以直接调用`ColumnFamilyData::GetSuperVersion`拿最新的SuperVersion。

## `rocksdb.stats`

```cpp
std::string rocksdb_stats;
db->GetProperty("rocksdb.stats", &rocksdb_stats)
```

其中Compaction Stats里每行是以该level为output level的compaction的stats，`Rn`是non output level的读取量，`Rnp1`是output level的读取量，其中`p1`应该是`plus 1`的意思。`Rn`和`Rnp1`相加就是`Read`。

## Secondary cache

官方文档：<https://github.com/facebook/rocksdb/wiki/SecondaryCache-(Experimental)>

官方讲解：<https://rocksdb.org/blog/2021/05/27/rocksdb-secondary-cache.html>

### CompressedSecondaryCacheOptions (in-memory)

```cpp
  rocksdb::CompressedSecondaryCacheOptions secondary_cache_opts;
  secondary_cache_opts.capacity = 字节数;
  secondary_cache_opts.compression_type = CompressionType的某一项;
  rocksdb::LRUCacheOptions lru_cache_opts;
  lru_cache_opts.capacity = 字节数;
  lru_cache_opts.secondary_cache =
      NewCompressedSecondaryCache(secondary_cache_opts);
  rocksdb::BlockBasedTableOptions table_options;
  table_options.block_cache = rocksdb::NewLRUCache(lru_cache_opts);
  rocksdb::Options options;
  options.table_factory.reset(
      rocksdb::NewBlockBasedTableFactory(table_options));
```

### RocksCachelibWrapper

<https://github.com/facebook/CacheLib/blob/main/cachelib/adaptor/rocks_secondary_cache/CachelibWrapper.h>

```cpp
facebook::rocks_secondary_cache::RocksCachelibWrapper
```

可惜其中有一部分没有开源，所以无法编译：<https://github.com/facebook/CacheLib/issues/278>

其实只要把`CachelibWrapper.h`和`CachelibWrapper.cpp`这两个文件拷贝到自己的project里，然后把里面引用了facebook内部代码的代码删掉即可：<https://github.com/seekstar/RocksCachelibWrapper>

相关：

<https://github.com/facebook/rocksdb/issues/8347>

<https://github.com/facebook/CacheLib/pull/184>
