---
title: 'rocksdb src/tcmalloc.cc:332] Attempt to free invalid pointer 0x556bc8784010'
date: 2022-01-01 14:04:26
tags:
---

编译的时候要加```-ltcmalloc```。

完整命令：

编译：

```shell
g++ -I$HOME/git/shared_lib/rocksdb/include -L$HOME/git/shared_lib/rocksdb/ simple_example.cc -lrocksdb -lpthread -ltcmalloc -o simple_example
```

运行：

```
LD_LIBRARY_PATH=~/git/shared_lib/rocksdb/ ./simple_example
```

这里面没有加这个也能跑：[RocksDB简单使用](https://www.jianshu.com/p/f233528c8303)。可能是因为新版本才需要加这个？

我咋知道要加这个的？观察```make shared_lib```之后生成的```make_config.mk```，发现里面跟malloc有关的有```-ltcmalloc```，所以尝试在编译的时候加```-ltcmalloc```，就解决这个问题了。我也不是很清楚是什么原理。
