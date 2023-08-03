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

`DBImpl::WriteImpl`先检查了一堆option，这里我们先不管。然后将`WriteBatch *my_batch`以及`WriteOption`都转移到了`WriteThread::Writer w`中。然后调用`WriteThread::JoinBatchGroup`。

- 假如我们不是leader

leader可能帮我们做了插入，这时直接返回即可。

如果leader告诉我们要自己插入到MemTable，那么调用`WriteBatchInternal::InsertInto`把数据插入到MemTable中，然后返回。

- 假如我们是leader（每个时刻只有一个leader）

>调用`DBImpl::PreprocessWrite`
>>如果`flush_scheduler_`中有任务，就调用`DBImpl::ScheduleFlushes`（唯一调用者）。
>>>先调用`FlushScheduler::TakeNextColumnFamily`（正常状态下唯一调用者），它是唯一从`FlushScheduler`中取出flush任务（以`ColumnFamilyData`的形式）的方法。
>>>逐个将这些取出的`ColumnFamilyData cfd`作为参数调用`DBImpl::SwitchMemtable`，将这些column family data的memory table变成immutable memory table，然后新建一个memory table。这里没有用原子操作，但是其他非leader的writer应该是没有拿DB mutex的。可能这是因为其他非leader的writer都在等leader给出指示。具体没细看。
>>>将之前取出的`ColumnFamilyData cfd`作为`DBImpl::GenerateFlushRequest`的参数，得到`FlushRequest flush_req`，再将其作为`DBImpl::SchedulePendingFlush`的参数。
>>>`DBImpl::SchedulePendingFlush`中，将给传进来的`flush_req`里的`cfd`做`cfd->Ref()`，然后加入到`DBImpl::flush_queue_`里。
>>>接下来的flush流程看这里：{% post_link Storage/"RocksDB代码分析——Flush流程" %}
>
>写入WAL
>调用`WriteBatchInternal::InsertInto`把数据插入到MemTable。

`WriteBatchInternal::InsertInto`中先构造了`MemTableInserter inserter`，然后执行`writer->batch->Iterate(&inserter)`，即执行`WriteBatch::Iterate(Handler* handler)`，其中handler其实是`MemTableInserter*`类型的。`WriteBatch::Iterate`中调用了`WriteBatchInternal::Iterate`，

`WriteBatchInternal::Iterate`中将WriteBatch中的record逐个读出来，按照record上的tag执行相应的操作。我们这里只关注tag为`kTypeValue`和`kTypeColumnFamilyValue`的record，对这种record，执行`handler->PutCF(column_family, key, value)`，即调用`WriteBatch::Handler::PutCF`，将对应的key和value插入。`WriteBatch::Handler::PutCF`是个virtual函数，注意到这里的`handler`其实是`MemTableInserter*`类型的，所以这里调用的其实是`MemTableInserter::PutCF`。`MemTableInserter::PutCF`中又调用了`MemTableInserter::PutCFImpl`。

`MemTableInserter::PutCFImpl`先调用`MemTable::Add`将key和value插入到MemTable中，再调用`MemTableInserter::CheckMemtableFull`。

`MemTableInserter::CheckMemtableFull`大意：

```cpp
if (cfd->mem()->ShouldScheduleFlush())
    flush_scheduler_->ScheduleWork(cfd);
```

`FlushScheduler::ScheduleWork`中，先`cfd->Ref()`，然后把cfd放进链表里。前面提到了，在`DBImpl::WriteImpl`中作为leader时，会检查`FlushScheduler flush_scheduler_`中有没有任务，有的话就拿出来放到`DBImpl::flush_queue_`中。

我的问题：为什么不直接放到`DBImpl::flush_queue_`中？
