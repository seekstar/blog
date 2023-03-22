---
title: RocksDB代码分析——Compaction流程
date: 2022-03-08 15:40:17
tags: RocksDB
---

这里从`DBImpl::MaybeScheduleFlushOrCompaction`开始讲起。

`DBImpl::MaybeScheduleFlushOrCompaction`可能会schedule`DBImpl::BGWorkFlush`和`DBImpl::BGWorkCompaction`。这里主要看Compaction。Flush部分见 {% post_link Storage/'RocksDB代码分析——Flush流程' %}

`DBImpl::BGWorkCompaction`中调用了`DBImpl::BackgroundCallCompaction`。

`DBImpl::BackgroundCallCompaction`中先锁住`DBImpl::mutex_`，保护DB元数据，然后调用`DBImpl::BackgroundCompaction`，然后调用`DBImpl::MaybeScheduleFlushOrCompaction`，我的理解是compaction完成之后下一层可能过大了，这样就需要做新的compaction。`DBImpl::BackgroundCallCompaction`返回的时候会自动把`DBImpl::mutex_`给释放掉。

`DBImpl::BackgroundCompaction`中：

- 如果不是`prepicked compaction`，那么：

>调用`DBImpl::PickCompactionFromQueue`从`compaction_queue_`里取出一个`ColumnFamilyData *cfd`
>调用`cfd->PickCompaction`，得到`Compaction *`，作为要做的任务。
>>`ColumnFamilyData::PickCompaction`调用`compaction_picker_->PickCompaction`。
>>`ColumnFamilyData::compaction_picker_`是在`ColumnFamilyData`的构造函数里根据`ioptions_.compaction_style`赋值的。
>>
>>```cpp
>>struct AdvancedColumnFamilyOptions {
>>  // The compaction style. Default: kCompactionStyleLevel
>>  CompactionStyle compaction_style = kCompactionStyleLevel;
>>```
>>
>>所以我们假设`ColumnFamilyData::compaction_picker_`是`LevelCompactionPicker`，即假设`ColumnFamilyData::PickCompaction`调用的`compaction_picker_->PickCompaction`其实是`LevelCompactionPicker::PickCompaction`。
>>`LevelCompactionPicker::PickCompaction`调用`LevelCompactionBuilder::PickCompaction`。
>>>选择输入文件：{% post_link Storage/'RocksDB代码分析——Compaction的输入文件的选择' %}
>>>调用`LevelCompactionBuilder::GetCompaction`构造`Compaction`对象。
>>>>将要返回的`Compaction *`中的score会被设置为start level的score。
>>>>在`Compaction`的构造函数中调用`Compaction::MarkFilesBeingCompacted`将输入文件标记为`being_compacted`，防止出现一边compaction一边上面compact到输入层的情况。
>>>>调用`VersionStorageInfo::ComputeCompactionScore`重新计算各层的score。
>>>>>除了Level 0，其他层的score等于没有在compact的file的`compensated_file_size`除以该层的最大字节数。
>>>>>只有score>=1的层才会被选择作为compaction的start level，见`LevelCompactionBuilder::SetupInitialFiles`（{% post_link Storage/'RocksDB代码分析——Compaction的输入文件的选择' %}）。
>>>>>file的`compensated_file_size`在`VersionStorageInfo::ComputeCompensatedSizes`中计算得到。

- 如果是`prepicked compaction`，那么就将`prepicked_compaction->compaction`作为要做的compaction任务。

`DBImpl::BackgroundCompaction`中，取出compaction任务后：

- 如果是最底层的compaction，而且不是`prepicked compaction`，那么就把priority改成`BOTTOM`，并且设置成`prepicked_compaction`，然后schedule `DBImpl::BGWorkBottomCompaction`，这个函数其实最后还是回到了`DBImpl::BackgroundCompaction`。这其实就相当于推迟bottom level的compaction。

- 如果是`prepicked compaction`，或者不是最底层的compaction，那么：

>构造`CompactionJob compaction_job`，其中`FSDirectory* output_directory`被设置成`GetDataDir(c->column_family_data(), c->output_path_id())`
>`mutex_.Unlock()`，执行`compaction_job.Run()`，再`mutex_.Lock()`。`DBImpl::mutex_`最开始是在`DBImpl::BackgroundCallCompaction`里锁住用来保护数据库元数据的，这里要执行耗时操作了，所以暂时把锁放开。
>`compaction_job.Install`
>
>>`CompactionJob::InstallCompactionResults`
>>
>>>先把输入文件删掉：`compaction->AddInputDeletions(edit);`
>>>再把输出文件加上：`edit->AddFile`
>
>`Compaction::ReleaseCompactionFiles`，将输入文件的`being_compacted`标志清除。

## CompactionJob::output_directory

它决定了compaction的结果应该放到哪个文件夹中。这里探究一下它是怎么确定的。

构造`CompactionJob`时，`FSDirectory* output_directory`被设置成`GetDataDir(c->column_family_data(), c->output_path_id())`。

`c->output_path_id()`返回的是`Compaction::output_path_id_`。它是从Compaction的构造函数的参数来的。

假如compaction任务（`Compaction`）是通过`cfd->PickCompaction`得到的。根据前面的分析，这些compaction任务默认是由`LevelCompactionBuilder::GetCompaction`构造的，其中`output_path_id`: `GetPathId(ioptions_, mutable_cf_options_, output_level_)`

```cpp
/*
 * Find the optimal path to place a file
 * Given a level, finds the path where levels up to it will fit in levels
 * up to and including this path
 */
uint32_t LevelCompactionBuilder::GetPathId(
    const ImmutableCFOptions& ioptions,
    const MutableCFOptions& mutable_cf_options, int level) {
```

大意就是检查`ImmutableCFOptions::cf_paths`的每个`cf_path`，直到找到某个path能放下要compact到的那个level。

这个`ImmutableCFOptions`的来源见{% post_link Storage/'RocksDB代码分析——各种option的传递' %}
