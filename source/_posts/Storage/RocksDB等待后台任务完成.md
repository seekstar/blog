---
title: RocksDB等待后台任务完成
date: 2022-04-15 22:09:58
tags: RocksDB
---

如果在RocksDB内部，可以用这个：

```cpp
void DBImpl::WaitForBackgroundWork() {
  // Wait for background work to finish
  while (bg_bottom_compaction_scheduled_ || bg_compaction_scheduled_ ||
         bg_flush_scheduled_) {
    bg_cv_.Wait();
  }
}
```

但是这个接口没有暴露给外部用户。但是外部用户也可以通过`GetIntProperty`来获得running/pending的flush/compaction的数目，如果它们其中有一个不为0，就说明有后台任务没有完成。因此对外部用户来说，可以这样等待后台任务完成：

```cpp
bool has_background_work(rocksdb::DB *db) {
	uint64_t flush_pending;
	uint64_t compaction_pending;
	uint64_t flush_running;
	uint64_t compaction_running;
	bool ok =
		db->GetIntProperty(
			rocksdb::Slice("rocksdb.mem-table-flush-pending"), &flush_pending);
	assert(ok);
	ok = db->GetIntProperty(
			rocksdb::Slice("rocksdb.compaction-pending"), &compaction_pending);
	assert(ok);
	ok = db->GetIntProperty(
			rocksdb::Slice("rocksdb.num-running-flushes"), &flush_running);
	assert(ok);
	ok = db->GetIntProperty(
			rocksdb::Slice("rocksdb.num-running-compactions"),
			&compaction_running);
	assert(ok);
	return flush_pending || compaction_pending || flush_running ||
		compaction_running;
}

void wait_for_background_work(rocksdb::DB *db) {
	while (1) {
		if (has_background_work(db)) {
			std::this_thread::sleep_for(std::chrono::seconds(1));
			continue;
		}
		// The properties are not get atomically. Test for more 20 times.
		int i;
		for (i = 0; i < 20; ++i) {
			std::this_thread::sleep_for(std::chrono::milliseconds(100));
			if (has_background_work(db)) {
				break;
			}
		}
		if (i == 20) {
			std::cout << "There is no background work detected for more than 2 seconds. Exiting...\n";
			break;
		}
	}
}
```

注意由于这几个值不是原子地获取的，因此在非常罕见的情况下，有可能出现这种情况：running/pending的flush/compaction的数目并不同时为0，但是`has_background_work`返回`false`。但是由于这里检测了至少21次，因此21次都出现这么罕见的情况的可能性微乎其微，可以忽略。
