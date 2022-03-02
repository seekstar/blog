---
title: 'RocksDB将上面几层放到快速设备,下面几层放到慢速设备'
date: 2022-03-02 22:07:42
tags: RocksDB
---

可以通过设置`DBOptions::db_paths`实现，代码里的相关注释：

```cpp
  // A list of paths where SST files can be put into, with its target size.
  // Newer data is placed into paths specified earlier in the vector while
  // older data gradually moves to paths specified later in the vector.
  //
  // For example, you have a flash device with 10GB allocated for the DB,
  // as well as a hard drive of 2TB, you should config it to be:
  //   [{"/flash_path", 10GB}, {"/hard_drive", 2TB}]
  //
  // The system will try to guarantee data under each path is close to but
  // not larger than the target size. But current and future file sizes used
  // by determining where to place a file are based on best-effort estimation,
  // which means there is a chance that the actual size under the directory
  // is slightly more than target size under some workloads. User should give
  // some buffer room for those cases.
  //
  // If none of the paths has sufficient room to place a file, the file will
  // be placed to the last path anyway, despite to the target size.
  //
  // Placing newer data to earlier paths is also best-efforts. User should
  // expect user files to be placed in higher levels in some extreme cases.
  //
  // If left empty, only one path will be used, which is db_name passed when
  // opening the DB.
  // Default: empty
  std::vector<DbPath> db_paths;
```

例子：假设快速存储设备挂载到了`/tmp/sd`上，慢速存储设备挂载到了`/tmp/cd`上，数据库的主目录放到`/tmp/rocksdb`里。把如下内容保存为`test.cpp`

```cpp
#include <iostream>
#include <filesystem>
#include <fstream>
#include <cstdint>

#include "rocksdb/db.h"

using namespace std;

int main(int argc, char **argv) {
    rocksdb::Options options;
    options.db_paths = {{"/tmp/sd", 100000000}, {"/tmp/cd", 1000000000}}; // 100MB, 1GB
    rocksdb::DB *db;
    options.create_if_missing = true;
    auto s = rocksdb::DB::Open(options, "/tmp/rocksdb", &db);
    for (uint64_t i = 0; i < 10000000; ++i) {
        rocksdb::Slice key_slice((const char *)&i, 8);
        rocksdb::Slice value_slice((const char *)&i, 8);
        auto s = db->Put(rocksdb::WriteOptions(), key_slice, value_slice);
        if (!s.ok()) {
            std::cout << "Put failed with error: " << s.ToString() << std::endl;
            delete db;
            return -1;
        }
    }
    delete db;
    return 0;
}
```

编译运行，记得把RocksDB的路径换成自己机器上的：

```shell
rm -rf /tmp/rocksdb/ && rm -rf /tmp/sd/* && rm -rf /tmp/cd/*
g++ test.cpp -o test -lrocksdb -I/home/searchstar/git/master/rocksdb/include/ -L/home/searchstar/git/master/rocksdb/build/
LD_LIBRARY_PATH=~/git/master/rocksdb/build/ ./test
```

查看设备的占用情况：

```shell
du -sh /tmp/rocksdb/ /tmp/sd /tmp/cd
```

输出：

```text
17M     /tmp/rocksdb/
100M    /tmp/sd
133M    /tmp/cd
```
