---
title: RocksDB代码分析——读取流程
date: 2023-12-07 21:38:51
tags:
---

分析均基于`v6.27.3`。以下流程为了方便理解均经过了简化。

首先，我们通过调用`DB::Open`来创建数据库，它返回了一个`DB*`。`DB::Open`内部调用了`DBImpl::Open`，在里面构造了一个`DBImpl*`并转换成`DB*`返回。所以我们拿到的`DB*`其实是`DBImpl*`。

然后我们调用`DB::Get`来读取数据。`DB::Get`是个virtual函数，它被`DBImpl::Get`给override了。

`DBImpl::Get`里调用了`DBImpl::GetImpl`。

`DBImpl::GetImpl`中，先调用`DBImpl::GetAndRefSuperVersion`拿到thread local的super version，然后调用`MemTable::Get`读取memory table和immutable memory table，如果找到了就返回，否则调用`Version::Get`继续在`sv->current`里查找。

`Version::Get`中，首先将key装进`GetContext`，然后遍历每个key range包含这个key的SSTable，把`GetContext`作为参数调用`TableCache::Get`来查找这个SSTable。如果都没找到就返回not found。

`TableCache::Get`中，调用`TableReader::Get`

Table默认是`BlockBasedTable`，所以这里的`TableReader`应该是`BlockBasedTable`的reader：

```cpp
class BlockBasedTable : public TableReader {
```

`BlockBasedTable::Get`中，调用`BlockBasedTable::NewIndexIterator`获得block index的iterator，然后遍历key range包含目标key的data block。对每个遍历到的data block，调用`BlockBasedTable::NewDataBlockIterator`构造`DataBlockIter biter`，然后seek next在里面查找key。

`BlockBasedTable::NewDataBlockIterator`中，调用`BlockBasedTable::RetrieveBlock`，将块存入`CachableEntry<Block> block`。

`BlockBasedTable::RetrieveBlock`中，参数`use_cache=true`，所以调用`BlockBasedTable::MaybeReadBlockAndLoadToCache`。

`BlockBasedTable::MaybeReadBlockAndLoadToCache`中，参数`contents=nullptr`，所以调用`BlockBasedTable::GetDataBlockFromCache`，如果miss的话就调用`BlockFetcher::ReadBlockContents`。

`BlockFetcher::ReadBlockContents`中，先尝试从persistent cache和prefetch buffer中读取。如果不成功的话，就调用`RandomAccessFileReader::Read`从文件中读取。
