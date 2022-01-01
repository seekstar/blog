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

其实写个Makefile也可以：

```Makefile
ROCKSDB_DIR := /home/searchstar/git/shared_lib/rocksdb/

include $(ROCKSDB_DIR)/make_config.mk

ifndef DISABLE_JEMALLOC
	ifdef JEMALLOC
		PLATFORM_CXXFLAGS += -DROCKSDB_JEMALLOC -DJEMALLOC_NO_DEMANGLE
	endif
	EXEC_LDFLAGS := $(JEMALLOC_LIB) $(EXEC_LDFLAGS) -lpthread
	PLATFORM_CXXFLAGS += $(JEMALLOC_INCLUDE)
endif

ifneq ($(USE_RTTI), 1)
	CXXFLAGS += -fno-rtti
endif

CFLAGS += -Wstrict-prototypes

.PHONY: clean librocksdb

all: simple_example

simple_example: librocksdb simple_example.cc
	$(CXX) $(CXXFLAGS) $@.cc -o$@ -L$(ROCKSDB_DIR)/ -I$(ROCKSDB_DIR)/include -O2 -std=c++11 $(PLATFORM_LDFLAGS) $(PLATFORM_CXXFLAGS) $(EXEC_LDFLAGS) -lrocksdb

clean:
	rm -rf ./simple_example

librocksdb:
	cd $(ROCKSDB_DIR) && $(MAKE) shared_lib
```

```shell
make
LD_LIBRARY_PATH=~/git/shared_lib/rocksdb/ ./simple_example
```

输出：

```
cd /home/searchstar/git/shared_lib/rocksdb/ && make shared_lib
make[1]: Entering directory '/home/searchstar/git/shared_lib/rocksdb'
$DEBUG_LEVEL is 0
make[1]: Nothing to be done for 'shared_lib'.
make[1]: Leaving directory '/home/searchstar/git/shared_lib/rocksdb'
g++ -fno-rtti simple_example.cc -osimple_example -L/home/searchstar/git/shared_lib/rocksdb// -I/home/searchstar/git/shared_lib/rocksdb//include -O2 -std=c++11 -lpthread -lrt -ldl -lsnappy -lgflags -lz -lbz2 -llz4 -lzstd -ltbb -ltcmalloc -std=c++11  -faligned-new -DHAVE_ALIGNED_NEW -DROCKSDB_PLATFORM_POSIX -DROCKSDB_LIB_IO_POSIX  -DOS_LINUX -fno-builtin-memcmp -DROCKSDB_FALLOCATE_PRESENT -DSNAPPY -DGFLAGS=1 -DZLIB -DBZIP2 -DLZ4 -DZSTD -DTBB -DROCKSDB_MALLOC_USABLE_SIZE -DROCKSDB_PTHREAD_ADAPTIVE_MUTEX -DROCKSDB_BACKTRACE -DROCKSDB_RANGESYNC_PRESENT -DROCKSDB_SCHED_GETCPU_PRESENT -DROCKSDB_AUXV_GETAUXVAL_PRESENT -march=native   -DHAVE_SSE42  -DHAVE_PCLMUL  -DHAVE_AVX2  -DHAVE_BMI  -DHAVE_LZCNT -DHAVE_UINT128_EXTENSION -DROCKSDB_SUPPORT_THREAD_LOCAL   -ldl -lpthread -lrocksdb
```

感觉这个会更靠谱一些。这个Makefile是照着官方给的静态库的Makefile改的：<https://github.com/facebook/rocksdb/blob/main/examples/Makefile>
