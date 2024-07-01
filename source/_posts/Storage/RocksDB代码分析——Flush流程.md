---
title: RocksDB代码分析——Flush流程
date: 2022-03-03 15:22:47
tags: RocksDB
---

这里从`DBImpl::MaybeScheduleFlushOrCompaction`开始讲起。

`DBImpl::MaybeScheduleFlushOrCompaction`可能会schedule`DBImpl::BGWorkFlush`和`DBImpl::BGWorkCompaction`。这里主要看Flush。Compaction部分见：{% post_link Storage/'RocksDB代码分析——Compaction流程' %}

`DBImpl::BGWorkFlush`中调用了`DBImpl::BackgroundCallFlush`。

`DBImpl::BackgroundCallFlush`中先上DB锁，然后调用`DBImpl::BackgroundFlush`，最后再调用`DBImpl::MaybeScheduleFlushOrCompaction`。

`DBImpl::BackgroundFlush`中先调用`DBImpl::PopFirstFromFlushQueue`从`DBImpl::flush_queue_`中取出`FlushRequest flush_req`（唯一的取出者），从中再取出`ColumnFamilyData`。再把这些`ColumnFamilyData`放进`bg_flush_args`，作为`DBImpl::FlushMemTablesToOutputFiles`的参数。`DBImpl::flush_queue_`里的`FlushRequest`的来源见：{% post_link Storage/"RocksDB代码分析——写入流程" %}。最后再将这些`ColumnFamilyData`给`UnrefAndTryDelete`。

`DBImpl::FlushMemTablesToOutputFiles`中，如果不是atomic_flush（默认），那么一定只有一个要flush的MemTable。把`ColumnFamilyData`拿出来，作为参数传给`DBImpl::FlushMemTableToOutputFile`。

>构造`FlushJob flush_job`
>`flush_job.PickMemTable()`，把MemTable的`VersionEdit`存在`FlushJob::edit_`里。
>`flush_job.Run`，也就是调用`FlushJob::Run`
>>调用`FlushJob::WriteLevel0Table`
>>>`db_mutex_->Unlock();`
>>>`BuildTable`
>>>`db_mutex_->Lock();`
>>>`edit_->AddFile`。这个`edit_`实际上是MemTable的VersionEdit
>>
>>调用`MemTableList::TryInstallMemtableFlushResults`
>>>将被flush的memory table的`flush_completed_`标记为`true`。
>>>从老到新把所有`flush_completed_`的immutable memory table的`VersionEdit`存进`edit_list`，然后通过`VersionSet::LogAndApply` commit这些edit，里面调用`VersionSet::ProcessManifestWrites`。
>>>>调用`VersionBuilder::Apply`，里面调用`VersionBuilder::Rep::Apply`，里面调用`VersionBuilder::Rep::ApplyFileAddition`，最终将file_number存到`VersionBuilder::Rep::levels_[level].added_files`里。
>>>>调用`VersionBuilder::SaveTo`，里面调用`VersionBuilder::Rep::SaveTo`，里面调用`VersionBuilder::Rep::SaveSSTFilesTo`，先对`VersionBuilder::Rep::levels_[level].added_files`排序，L0的SSTable用`NewestFirstBySeqNo`排序，其他的用`BySmallestKey`排序，然后跟老version里已有的SSTable merge到一个新的version。
>
>把`ColumnFamilyData`作为参数调用`DBImpl::InstallSuperVersionAndScheduleWork`。
>>因为把MemTable写入到L0层之后总是会想要把这些SSTable给compact到L1层，所以接下来准备schedule compaction。
>>把`ColumnFamilyData`作为参数调用`DBImpl::SchedulePendingCompaction`
>>>将`ColumnFamilyData`传给`DBImpl::AddToCompactionQueue`，从而将其加入到`DBImpl::compaction_queue_`中。
>>
>>调用`DBImpl::MaybeScheduleFlushOrCompaction`
>>接下来的compaction流程看这里：{% post_link Storage/'RocksDB代码分析——Compaction流程' %}
