---
title: RocksDB静态库用法
date: 2022-01-01 14:29:37
tags:
---

照抄官方给的实例里的Makefile：<https://github.com/facebook/rocksdb/blob/main/examples/Makefile>

稍微改一点：

```Makefile
ROCKSDB_DIR := /home/searchstar/git/rocksdb/

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
	$(CXX) $(CXXFLAGS) $@.cc -o$@ $(ROCKSDB_DIR)/librocksdb.a -I$(ROCKSDB_DIR)/include -O2 -std=c++11 $(PLATFORM_LDFLAGS) $(PLATFORM_CXXFLAGS) $(EXEC_LDFLAGS)

clean:
	rm -rf ./simple_example

librocksdb:
	cd $(ROCKSDB_DIR) && $(MAKE) static_lib
```

```shell
make
./simple_example
```

输出：

```
cd /home/searchstar/git/rocksdb/ && make static_lib
make[1]: Entering directory '/home/searchstar/git/rocksdb'
$DEBUG_LEVEL is 0
make[1]: Nothing to be done for 'static_lib'.
make[1]: Leaving directory '/home/searchstar/git/rocksdb'
g++ -fno-rtti simple_example.cc -osimple_example /home/searchstar/git/rocksdb//librocksdb.a -I/home/searchstar/git/rocksdb//include -O2 -std=c++11 -lpthread -lrt -ldl -lsnappy -lgflags -lz -lbz2 -llz4 -lzstd -ltbb -ltcmalloc -std=c++11  -faligned-new -DHAVE_ALIGNED_NEW -DROCKSDB_PLATFORM_POSIX -DROCKSDB_LIB_IO_POSIX  -DOS_LINUX -fno-builtin-memcmp -DROCKSDB_FALLOCATE_PRESENT -DSNAPPY -DGFLAGS=1 -DZLIB -DBZIP2 -DLZ4 -DZSTD -DTBB -DROCKSDB_MALLOC_USABLE_SIZE -DROCKSDB_PTHREAD_ADAPTIVE_MUTEX -DROCKSDB_BACKTRACE -DROCKSDB_RANGESYNC_PRESENT -DROCKSDB_SCHED_GETCPU_PRESENT -DROCKSDB_AUXV_GETAUXVAL_PRESENT -march=native   -DHAVE_SSE42  -DHAVE_PCLMUL  -DHAVE_AVX2  -DHAVE_BMI  -DHAVE_LZCNT -DHAVE_UINT128_EXTENSION -DROCKSDB_SUPPORT_THREAD_LOCAL   -ldl -lpthread
```

我自己写的编译命令不管用，我也不知道为什么：

```shell
g++ -I$HOME/git/rocksdb/include simple_example.cc $HOME/git/rocksdb/librocksdb.a -lpthread -ltcmalloc -o simple_example
```

```
/usr/bin/ld: /home/searchstar/git/rocksdb/librocksdb.a(env_posix.o): in function `rocksdb::(anonymous namespace)::PosixDynamicLibrary::~PosixDynamicLibrary()':
/home/searchstar/git/rocksdb/env/env_posix.cc:108: undefined reference to `dlclose'
/usr/bin/ld: /home/searchstar/git/rocksdb/librocksdb.a(env_posix.o): in function `rocksdb::(anonymous namespace)::PosixDynamicLibrary::~PosixDynamicLibrary()':
/home/searchstar/git/rocksdb/env/env_posix.cc:108: undefined reference to `dlclose'
/usr/bin/ld: /home/searchstar/git/rocksdb/librocksdb.a(env_posix.o): in function `std::_Sp_counted_ptr<rocksdb::(anonymous namespace)::PosixDynamicLibrary*, (__gnu_cxx::_Lock_policy)2>::_M_dispose()':
/home/searchstar/git/rocksdb/env/env_posix.cc:108: undefined reference to `dlclose'
/usr/bin/ld: /home/searchstar/git/rocksdb/librocksdb.a(env_posix.o): in function `rocksdb::(anonymous namespace)::PosixDynamicLibrary::LoadSymbol(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, void**)':
/home/searchstar/git/rocksdb/env/env_posix.cc:112: undefined reference to `dlerror'
/usr/bin/ld: /home/searchstar/git/rocksdb/env/env_posix.cc:113: undefined reference to `dlsym'
/usr/bin/ld: /home/searchstar/git/rocksdb/env/env_posix.cc:117: undefined reference to `dlerror'
此处省略很多行
```
