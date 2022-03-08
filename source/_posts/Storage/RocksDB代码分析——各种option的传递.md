---
title: RocksDB代码分析——各种option的传递
date: 2022-03-08 15:58:35
tags: RocksDB
---

```cpp
struct Options : public DBOptions, public ColumnFamilyOptions {
struct ImmutableOptions : public ImmutableDBOptions, public ImmutableCFOptions {
```

## Options of column families

```cpp
Status DB::Open(const Options& options, const std::string& dbname, DB** dbptr) {
  DBOptions db_options(options);
  ColumnFamilyOptions cf_options(options);
  std::vector<ColumnFamilyDescriptor> column_families;
  column_families.push_back(
      ColumnFamilyDescriptor(kDefaultColumnFamilyName, cf_options));
...
    Status s = DB::Open(db_options, dbname, column_families, &handles, dbptr);
```

即从`Options`中取出`ColumnFamilyOptions`并且放到`default` column family里。

```cpp
Status DB::Open(const DBOptions& db_options, const std::string& dbname,
                const std::vector<ColumnFamilyDescriptor>& column_families,
                std::vector<ColumnFamilyHandle*>* handles, DB** dbptr) {
  const bool kSeqPerBatch = true;
  const bool kBatchPerTxn = true;
  return DBImpl::Open(db_options, dbname, column_families, handles, dbptr,
                      !kSeqPerBatch, kBatchPerTxn);
}
```

```cpp
Status DBImpl::Open(const DBOptions& db_options, const std::string& dbname,
                    const std::vector<ColumnFamilyDescriptor>& column_families,
                    std::vector<ColumnFamilyHandle*>* handles, DB** dbptr,
                    const bool seq_per_batch, const bool batch_per_txn) {
...
      for (auto cf : column_families) {
        ...
            s = impl->CreateColumnFamily(cf.options, cf.name, &handle);
        ...
```

`DBImpl::CreateColumnFamily`调用了`DBImpl::CreateColumnFamilyImpl`，`ColumnFamilyOptions`是参数。

`DBImpl::CreateColumnFamilyImpl`执行了`versions_->LogAndApply`，即调用了`VersionSet::LogAndApply`，`ColumnFamilyOptions`是参数。

`VersionSet::LogAndApply`调用了另一个版本的`VersionSet::LogAndApply`，`ColumnFamilyOptions`是参数。

另一个版本的`VersionSet::LogAndApply`调用了`VersionSet::ProcessManifestWrites`，`ColumnFamilyOptions`是参数。

`VersionSet::ProcessManifestWrites`调用了`VersionSet::CreateColumnFamily`，`ColumnFamilyOptions`是参数。

`VersionSet::CreateColumnFamily`执行了`column_family_set_->CreateColumnFamily`，即调用了`ColumnFamilySet::CreateColumnFamily`，`ColumnFamilyOptions`是参数。然后把返回的`ColumnFamilyData`返回回去。（这里的version list没搞懂）

`ColumnFamilySet::CreateColumnFamily`构造了`ColumnFamilyData`，把`db_options_`和自己的参数`const ColumnFamilyOptions& options`传进去。然后把构造好的`ColumnFamilyData`加入到自己的linked list里，最后返回回去。

`ColumnFamilyData`的构造函数中，经过一系列操作，把传进来的`ColumnFamilyOptions`和`ImmutableDBOptions`里的immutable部分放到`ImmutableOptions`类型的`ioptions_`里，mutable部分放到`MutableCFOptions`类型的`mutable_cf_options_`里。此外，`ColumnFamilyData`的构造函数中还初始化了`compaction_picker_`，并将自己的`ImmutableOptions`类型的`ioptions_`存一份到`LevelCompactionPicker::ioptions_`中。

所以这时，Column family的option就保存在`VersionSet`类型的`DBImpl::versions_`里的

`VersionSet::column_family_set_`里的linked list里的

`ColumnFamilyData`里的

`ImmutableOptions`类型的`ioptions_`和`MutableCFOptions`类型的`mutable_cf_options_`里。

## Options of DB

```cpp
Status DB::Open(const Options& options, const std::string& dbname, DB** dbptr) {
  DBOptions db_options(options);
...
  Status s = DB::Open(db_options, dbname, column_families, &handles, dbptr);
```

```cpp
Status DB::Open(const DBOptions& db_options, const std::string& dbname,
                const std::vector<ColumnFamilyDescriptor>& column_families,
                std::vector<ColumnFamilyHandle*>* handles, DB** dbptr) {
  const bool kSeqPerBatch = true;
  const bool kBatchPerTxn = true;
  return DBImpl::Open(db_options, dbname, column_families, handles, dbptr,
                      !kSeqPerBatch, kBatchPerTxn);
}
```

```cpp
  DBImpl* impl = new DBImpl(db_options, dbname, seq_per_batch, batch_per_txn);
```

在`DBImpl`的构造函数中，把`DBOptions`拆成了`mutable_db_options_`和`immutable_db_options_`。此外，还初始化了`versions_`，把`ImmutableDBOptions`存入了`DBImpl::versions_.column_family_set_.db_options_`，并且把`column_family_memtables_.column_family_set_`指针设置为`versions_.column_family_set_`。

## 写入路径上的option传递

`DBImpl::WriteImpl`中，通过`ColumnFamilyMemTablesImpl`类型的`column_family_memtables`能访问到`ImmutableDBOptions`和所有`ColumnFamilyOptions`。`column_family_memtables`作为参数传给`WriteBatchInternal::InsertInto`的`memtables`形参，类型转换为`ColumnFamilyMemTables`。

`WriteBatchInternal::InsertInto`中，把`memtables`保存到`inserter.cf_mems_`，此时`ColumnFamilyMemTablesImpl`是`inserter.cf_mems_`。`inserter`传给了`WriteBatch::Iterate`的`handler`形参。

`WriteBatch::Iterate`中，`ColumnFamilyMemTablesImpl`是`handler.cf_mems_`。调用`WriteBatchInternal::Iterate`，`handler`作为参数，名字不变。

`WriteBatchInternal::Iterate`中，`ColumnFamilyMemTablesImpl`是`handler.cf_mems_`。执行`handler->PutCF`，即调用`MemTableInserter::PutCF`。

`MemTableInserter::PutCF`中，`ColumnFamilyMemTablesImpl`是`cf_mems_`。调用`MemTableInserter::PutCFImpl`。

`MemTableInserter::PutCFImpl`中，`ColumnFamilyMemTablesImpl`是`cf_mems_`。先调用`MemTableInserter::SeekToColumnFamily`，在里面执行`cf_mems_->Seek(column_family_id)`，即调用`ColumnFamilyMemTablesImpl::Seek`，在里面设置`current_`。

`MemTableInserter::CheckMemtableFull`中，执行`cfd = cf_mems_->current()`，取出当前的column family的`ColumnFamilyData`，然后可能执行`flush_scheduler_->ScheduleWork(cfd)`。注意，通过`ColumnFamilyData`可以访问到`ImmutableOptions`和`MutableCFOptions`。

然后根据 {% post_link Storage/'RocksDB代码分析——写入流程' %}，一波操作之后`ColumnFamilyData`作为flush任务的载体被放到了`FlushRequest`里，进而被放进了`DBImpl::flush_queue_`里。

然后根据 {% post_link Storage/"RocksDB代码分析——Flush流程" %}，`DBImpl::BackgroundFlush`调用`DBImpl::PopFirstFromFlushQueue`从`DBImpl::flush_queue_`中取出`FlushRequest flush_req`，从中再取出`ColumnFamilyData`。一波操作之后`ColumnFamilyData`可能作为compaction任务的载体被放进`DBImpl::compaction_queue_`。

然后根据 {% post_link Storage/'RocksDB代码分析——Compaction流程' %}，`DBImpl::BackgroundCompaction`可能调用`DBImpl::PickCompactionFromQueue`从`compaction_queue_`里取出一个`ColumnFamilyData *cfd`，然后调用`cfd->PickCompaction`，得到`Compaction *`。

`ColumnFamilyData::PickCompaction`执行了`compaction_picker_->PickCompaction`，即调用了`LevelCompactionPicker::PickCompaction`。

`LevelCompactionPicker::PickCompaction`中构造了`LevelCompactionBuilder builder`，将`ImmutableOptions`类型的`LevelCompactionPicker::ioptions_`存入`LevelCompactionBuilder::ioptions_`。

由上文可知，`LevelCompactionPicker::ioptions_`是在构造`ColumnFamilyData`时初始化的，其`ioptions_`来自`ColumnFamilyData::ioptions_`。
