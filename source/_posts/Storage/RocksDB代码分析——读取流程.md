---
title: RocksDB代码分析——读取流程
date: 2023-12-07 21:38:51
tags:
---

以下流程为了方便理解均经过了简化。

首先，我们通过调用`DB::Open`来创建数据库，它返回了一个`DB*`。`DB::Open`内部调用了`DBImpl::Open`，在里面构造了一个`DBImpl*`并转换成`DB*`返回。所以我们拿到的`DB*`其实是`DBImpl*`。

## Get

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

## NewIterator

这里假设table是默认的BlockBasedTable。

`DB::NewIterator`实际是`DBImpl::NewIterator`。在其中调用`DBImpl::NewIteratorImpl`。

`DBImpl::NewIteratorImpl`中，先调用`NewArenaWrappedDbIterator`构造一个`ArenaWrappedDBIter* db_iter`，然后调用`DBImpl::NewInternalIterator`，在`db_iter`管理的Arena里构造`MergingIterator *internal_iter`。

`DBImpl::NewInternalIterator`中：

>`super_version->mem->NewIterator`, 构建memory table的iterator
>`super_version->imm->AddIterators`, 构建immutable memory table的iterator。
>调用`Version::AddIterators`，对每层都调用`Version::AddIteratorsForLevel`
>>L0的每个SSTable都调用`TableCache::NewIterator`。在里面调用`TableReader::NewIterator`。`TableReader`默认是`BlockBasedTable`，所以默认调用的是`BlockBasedTable::NewIterator`，创建一个`BlockBasedTableIterator`。
>>其他层每层构造一个LevelIterator
>把memory table的，immutable memory table的，L0的每个SSTable的`BlockBasedTableIterator`，以及其他层的`LevelIterator`都合并成一个`MergingIterator`返回。

## Seek

根据上文所述，`DB::NewIterator`返回的实际上是`ArenaWrappedDBIter`，所以`Iterator::Seek`调用的是`ArenaWrappedDBIter::Seek`。其中调用`DBIter::Seek`。其中调用`MergingIterator::Seek`。

`MergingIterator::Seek`中，对每个子iterator调用`Seek`，比如memory table的iterator，L0中每个SSTable的`BlockBasedTableIterator`，以及其他层的`LevelIterator`。然后构建子iterator的小根堆，按照子iterator `Seek`之后的key排序。`MergingIterator`的key和value就是key最小的子iterator的key和value。

`BlockBasedTableIterator::Seek`调用`BlockBasedTableIterator::SeekImpl`。

`BlockBasedTableIterator::SeekImpl`中

>如果有prefix bloom filter，就调用`BlockBasedTableIterator::CheckPrefixMayMatch`检查filter。如果filter返回negative就调用`ResetDataIter`把状态变成invalid然后返回。如果filter返回positive，就正常继续执行seek操作。
>通过block index找到数据属于哪个block。如果找不到，就调用`ResetDataIter`把状态变成invalid然后返回。找到了data block的话，调用`BlockBasedTableIterator::InitDataBlock`，在里面构建`block_iter_`，

## Next

`Iterator::Next`调用的是`ArenaWrappedDBIter::Next`。其中调用`DBIter::Next`。其中调用`MergingIterator::Next`。

`MergingIterator::Next`中，先给堆顶的子iterator调用`Next`。如果子iterator没有下一个了，就将其从堆里移出。否则调用`BinaryHeap::replace_top`来将这个原先在堆顶的子iterator往下挪，从而维护堆的性质。值得注意的是，LSM-tree通常越下面的sorted run越大，这就意味着当一个iterator在堆顶时，它倾向于保持在堆顶。可以证明，这种方式下，对于大于1的size ratio，每次`Next`里堆的维护成本均摊下来是常数。

对于同一个user key，`MergingIterator`会先返回sequence number大的，所以调用了`MergingIterator::Next`之后，下一个key可能是同一个user key，但是sequence number更小，也就是同一个user key的旧版本。而`DBIter`只需要返回一个最新版本即可。所以`DBIter::Next`接下来会调用`DBIter::FindNextUserEntry`，跳过那些可能的旧版本。值得注意的是，如果连续跳过的旧版本个数超过了`max_sequential_skip_in_iterations`，`DBIter`就会直接seek下一个user key（通过把seek key设置成那个user key并把sequence number置0）。

`max_sequential_skip_in_iterations`的注释：

```text
  // An iteration->Next() sequentially skips over keys with the same
  // user-key unless this option is set. This number specifies the number
  // of keys (with the same userkey) that will be sequentially
  // skipped before a reseek is issued.
  //
  // Default: 8
  //
  // Dynamically changeable through SetOptions() API
  uint64_t max_sequential_skip_in_iterations = 8;
```
