---
title: RocksDB代码分析——写入流程
date: 2022-03-03 13:30:21
tags: RocksDB
---

分析均基于`v6.27.3`。以下流程为了方便理解均经过了简化。

首先，我们通过调用`DB::Open`来创建数据库，它返回了一个`DB*`。`DB::Open`内部调用了`DBImpl::Open`，在里面构造了一个`DBImpl*`并转换成`DB*`返回。所以我们拿到的`DB*`其实是`DBImpl*`。

然后我们调用`DB::Put`来写入数据。`DB::Put`是个virtual函数，它被`DBImpl::Put`给override了：

```cpp
Status DBImpl::Put(const WriteOptions& o, ColumnFamilyHandle* column_family,
                   const Slice& key, const Slice& val) {
  return DB::Put(o, column_family, key, val);
}
```

它显式调用了`DB::Put`。`DB::Put`中首先构造了WriteBatch，然后调用了`DB::Write`，它是个纯虚函数，被`DBImpl::Write` override了。`DBImpl::Write`调用了`DBImpl::WriteImpl`。

`DBImpl::WriteImpl`先检查了一堆option，这里我们先不管。然后将`WriteBatch *my_batch`以及`WriteOption`都转移到了`WriteThread::Writer w`中。然后调用`WriteThread::JoinBatchGroup`。假如我们不是leader，那么调用`WriteBatchInternal::InsertInto`把数据插入到MemTable中，然后返回。假如我们是leader，那么我们负责写入WAL，然后调用`WriteBatchInternal::InsertInto`把数据插入到MemTable。

`WriteBatchInternal::InsertInto`中先构造了`MemTableInserter inserter`，然后执行`writer->batch->Iterate(&inserter)`，即执行`WriteBatch::Iterate(Handler* handler)`，其中handler其实是`MemTableInserter*`类型的。`WriteBatch::Iterate`中调用了`WriteBatchInternal::Iterate`，

`WriteBatchInternal::Iterate`中将WriteBatch中的record逐个读出来，按照record上的tag执行相应的操作。我们这里只关注tag为`kTypeValue`和`kTypeColumnFamilyValue`的record，对这种record，执行`handler->PutCF(column_family, key, value)`，即调用`WriteBatch::Handler::PutCF`，将对应的key和value插入。`WriteBatch::Handler::PutCF`是个virtual函数，注意到这里的`handler`其实是`MemTableInserter*`类型的，所以这里调用的其实是`MemTableInserter::PutCF`。`MemTableInserter::PutCF`中又调用了`MemTableInserter::PutCFImpl`。

`MemTableInserter::PutCFImpl`先调用`MemTable::Add`将key和value插入到MemTable中，再调用`MemTableInserter::CheckMemtableFull`。

`MemTableInserter::CheckMemtableFull`大意：

```cpp
if (cfd->mem()->ShouldScheduleFlush())
    flush_scheduler_->ScheduleWork(cfd);
```

然后后台线程会在适当的时间把flush任务取出来执行。
