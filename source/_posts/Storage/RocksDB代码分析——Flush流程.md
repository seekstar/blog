---
title: RocksDB代码分析——Flush流程
date: 2022-03-03 15:22:47
tags: RocksDB
---

这里从`DBImpl::MaybeScheduleFlushOrCompaction`开始讲起。

`DBImpl::MaybeScheduleFlushOrCompaction`可能会schedule`DBImpl::BGWorkFlush`和`DBImpl::BGWorkCompaction`。这里主要看Flush。Compaction部分见：{% post_link Storage/'RocksDB代码分析——Compaction流程' %}

`DBImpl::BGWorkFlush`中调用了`DBImpl::BackgroundCallFlush`。

`DBImpl::BackgroundCallFlush`中调用了`DBImpl::BackgroundFlush`，最后再调用`DBImpl::MaybeScheduleFlushOrCompaction`。

`DBImpl::BackgroundFlush`中先调用`DBImpl::PopFirstFromFlushQueue`从`DBImpl::flush_queue_`中取出`FlushRequest flush_req`（唯一的取出者），从中再取出`ColumnFamilyData`。再把这些`ColumnFamilyData`放进`bg_flush_args`，作为`DBImpl::FlushMemTablesToOutputFiles`的参数。`DBImpl::flush_queue_`里的`FlushRequest`的来源见：{% post_link Storage/"RocksDB代码分析——写入流程" %}

`DBImpl::FlushMemTablesToOutputFiles`中，如果不是atomic_flush（默认），那么一定只有一个要flush的MemTable。把`ColumnFamilyData`拿出来，作为参数传给`DBImpl::FlushMemTableToOutputFile`。

`DBImpl::FlushMemTableToOutputFile`中，构造`FlushJob flush_job`，然后执行`flush_job.Run`，也就是调用`FlushJob::Run`，然后把`ColumnFamilyData`作为参数调用`DBImpl::InstallSuperVersionAndScheduleWork`。

  `DBImpl::InstallSuperVersionAndScheduleWork`会把`ColumnFamilyData`作为参数调用`DBImpl::SchedulePendingCompaction`，以及调用`DBImpl::MaybeScheduleFlushOrCompaction`，因为把MemTable写入到L0层之后总是会想要把这些SSTable给compact到L1层。

  `DBImpl::SchedulePendingCompaction`将`ColumnFamilyData`传给`DBImpl::AddToCompactionQueue`，从而将其加入到`DBImpl::compaction_queue_`中。

  接下来的compaction流程看这里：{% post_link Storage/'RocksDB代码分析——Compaction流程' %}

`FlushJob::Run`中，调用`FlushJob::WriteLevel0Table`，把MemTable写入到L0层。
