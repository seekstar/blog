---
title: RocksDB代码分析——Flush流程
date: 2022-03-03 15:22:47
tags: RocksDB
---

这里从`DBImpl::MaybeScheduleFlushOrCompaction`开始讲起。

`DBImpl::MaybeScheduleFlushOrCompaction`可能会schedule`DBImpl::BGWorkFlush`和`DBImpl::BGWorkCompaction`。这里主要看Flush。

`DBImpl::BGWorkFlush`中调用了`DBImpl::BackgroundCallFlush`。

`DBImpl::BackgroundCallFlush`中调用了`DBImpl::BackgroundFlush`，最后再调用`DBImpl::MaybeScheduleFlushOrCompaction`。

`DBImpl::BackgroundFlush`中先调用`DBImpl::PopFirstFromFlushQueue`从`DBImpl::flush_queue_`中取出`FlushRequest flush_req`（唯一的取出者），然后调用`DBImpl::FlushMemTablesToOutputFiles`。`DBImpl::flush_queue_`里的`FlushRequest`的来源见：{% post_link Storage/"RocksDB代码分析——写入流程" %}

`DBImpl::FlushMemTablesToOutputFiles`中，如果不是atomic_flush（默认），那么一定只有一个要flush的MemTable。取出一些参数之后，调用`DBImpl::FlushMemTableToOutputFile`。

`DBImpl::FlushMemTableToOutputFile`中，构造`FlushJob flush_job`，然后执行`flush_job.Run`，也就是调用`FlushJob::Run`，然后调用`DBImpl::InstallSuperVersionAndScheduleWork`，在其中会调用`DBImpl::SchedulePendingCompaction`和`DBImpl::MaybeScheduleFlushOrCompaction`，因为把MemTable写入到L0层之后总是会想要把这些SSTable给compact到L1层。

`FlushJob::Run`中，调用`FlushJob::WriteLevel0Table`，把MemTable写入到L0层。
