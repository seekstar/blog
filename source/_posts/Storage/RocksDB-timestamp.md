---
title: RocksDB timestamp
date: 2022-03-09 21:04:48
tags: RocksDB
---

官方文档：<https://github.com/facebook/rocksdb/wiki/User-Timestamp-%28Experimental%29>

这是实验特性。大意就是每个record附加一个时间戳，然后用户读取的时候可以指定读取哪个时间戳以前的最新的record。所以如果启用了时间戳特性的话，旧版本的record不会被新版本的record覆盖。为了避免浪费太多空间，可以通过`SetFullHistoryTsLow`来trim掉不需要的history，早于这个时间点的record都会在compaction时被drop掉。
