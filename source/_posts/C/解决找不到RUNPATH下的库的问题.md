---
title: 解决找不到RUNPATH下的库的问题
date: 2023-12-25 01:18:00
tags:
---

这个问题困扰了我很久，受GPT4的指点才解决的，这里记录一下解决问题的过程。

## 症状

```text
$ ldd rocksdb-kvexe
        libfolly.so.0.58.0-dev => /home/admin/opt/cachelib/lib/libfolly.so.0.58.0-dev (0x00007ff382e00000)
        libthrift-core.so.1.0.0 => not found

$ ./rocksdb-kvexe 
./rocksdb-kvexe: error while loading shared libraries: libthrift-core.so.1.0.0: cannot open shared object file: No such file or directory
```

找不到这个库：`libthrift-core.so.1.0.0`。它在这里：

```text
$ stat /home/admin/opt/cachelib/lib/libthrift-core.so.1.0.0
  File: /home/admin/opt/cachelib/lib/libthrift-core.so.1.0.0
  Size: 187504          Blocks: 368        IO Block: 4096   regular file
Device: 259,2   Inode: 950220      Links: 1
Access: (0644/-rw-r--r--)  Uid: ( 1000/   admin)   Gid: ( 1000/   admin)
Access: 2023-12-24 16:23:10.233856940 +0000
Modify: 2023-12-23 12:44:00.000000000 +0000
Change: 2023-12-23 12:49:50.050831528 +0000
 Birth: 2023-12-23 12:49:50.050831528 +0000
```

我们检查一下`RUNPATH`：

```shell
readelf -d rocksdb-kvexe | grep PATH
 0x000000000000001d (RUNPATH)            Library runpath: [/home/admin/rocksdb/build:/home/admin/opt/cachelib/lib]
```

它已经包含了`libthrift-core.so.1.0.0`所在的目录`/home/admin/opt/cachelib/lib`。说明`RUNPATH`没有问题。而且跟它同目录的`libfolly.so.0.58.0-dev`也找到了，说明问题不是出在binary的`RUNPATH`上。

## 排查问题

GPT4建议我用`LD_DEBUG=libs`来debug链接的过程：

```shell
LD_DEBUG=libs ./rocksdb-kvexe
```

其中有这样一段：

```text
   1654057:     find library=libthrift-core.so.1.0.0 [0]; searching
   1654057:      search path=/home/admin/CacheLib/opt/cachelib/lib/glibc-hwcaps/x86-64-v4:/home/admin/CacheLib/opt/cachelib/lib/glibc-hwcaps/x86-64-v3:/home/admin/CacheLib/opt/cachelib/lib/glibc-hwcaps/x86-64-v2:/home/admin/CacheLib/opt/cachelib/lib/tls/haswell/avx512_1/x86_64:/home/admin/CacheLib/opt/cachelib/lib/tls/haswell/avx512_1:/home/admin/CacheLib/opt/cachelib/lib/tls/haswell/x86_64:/home/admin/CacheLib/opt/cachelib/lib/tls/haswell:/home/admin/CacheLib/opt/cachelib/lib/tls/avx512_1/x86_64:/home/admin/CacheLib/opt/cachelib/lib/tls/avx512_1:/home/admin/CacheLib/opt/cachelib/lib/tls/x86_64:/home/admin/CacheLib/opt/cachelib/lib/tls:/home/admin/CacheLib/opt/cachelib/lib/haswell/avx512_1/x86_64:/home/admin/CacheLib/opt/cachelib/lib/haswell/avx512_1:/home/admin/CacheLib/opt/cachelib/lib/haswell/x86_64:/home/admin/CacheLib/opt/cachelib/lib/haswell:/home/admin/CacheLib/opt/cachelib/lib/avx512_1/x86_64:/home/admin/CacheLib/opt/cachelib/lib/avx512_1:/home/admin/CacheLib/opt/cachelib/lib/x86_64:/home/admin/CacheLib/opt/cachelib/lib(RUNPATH from file /home/admin/opt/cachelib/lib/libthriftprotocol.so.1.0.0)
```

可以看到，`libthrift-core.so.1.0.0`是`libthriftprotocol.so.1.0.0`的dependency，所以查找`libthrift-core.so.1.0.0`的时候会在`libthriftprotocol.so.1.0.0`的RUNPATH而不是`rocksdb-kvexe`的RUNPATH里找，而`libthriftprotocol.so.1.0.0`的RUNPATH是错误的，导致了`libthrift-core.so.1.0.0`找不到。

## 解决方案

GPT4说可以直接用`patchelf --set-rpath`来更正library的RUNPATH:

```shell
cd ~/opt/cachelib/lib
patchelf --set-rpath $(pwd) libthriftprotocol.so.1.0.0
```

问题解决。

注意不能把RUNPATH设置成相对路径，因为链接器在RUNPATH里找的时候是在当前工作目录解析RUNPATH的，而不会相对于库的路径去解析RUNPATH里的相对路径。
