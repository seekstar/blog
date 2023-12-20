---
title: C++内存占用分析
date: 2023-10-25 20:43:07
tags:
---

## heaptrack

可以打印出消耗内存最多的地方、申请内存次数最多的地方、临时申请内存最多的地方。

运行速度差不多是正常运行的三四倍。输出的trace虽然经过了压缩，但还是很大。

<https://milianw.de/blog/heaptrack-a-heap-memory-profiler-for-linux.html>

官方文档：

<https://github.com/KDE/heaptrack>

<https://github.com/KDE/heaptrack#heaptrack_print>

```shell
sudo apt install heaptrack
```

```shell
heaptrack 可执行文件 参数...
```

```shell
heaptrack_print xxx.gz > report
```

有几个section:

### `MOST CALLS TO ALLOCATION FUNCTIONS`

### `PEAK MEMORY CONSUMERS`

会从大到小列出分配内存最多的位置：

<内存大小> peak memory consumed over <数量> calls from
分配内存的位置

有很多地方会调用这个位置。所以heaptrack会根据分配内存的总大小从大到小列出调用这个位置的调用栈：

<内存大小> consumed over <数量> calls from:
调用栈1...
<内存大小> consumed over <数量> calls from:
调用栈2...
<内存大小> consumed over <数量> calls from:
调用栈3...
...

### `MOST TEMPORARY ALLOCATIONS`

### 最后的summary

#### peak heap memory consumption

注意，这里是程序实际使用的heap memory，而不是整个heap占用的memory。如果使用的是glibc的内存分配器，可能会出现peak RSS显著大于peak heap memory consumption的情况，这可能是因为内存分配器出现了碎片化，导致程序实际使用的heap memory显著小于heap实际占用的memory：<https://blog.cloudflare.com/the-effect-of-switching-to-tcmalloc-on-rocksdb-memory-use/>

可以通过把glibc的内存分配器换成tcmalloc解决。jemalloc虽然比glibc和tcmalloc快，但是在碎片化严重的情况下内存消耗比较大：<https://github.com/cms-sw/cmssw/issues/42387>

rocksdb的cmake自带了使用jemalloc的选项：`WITH_JEMALLOC`，但是使用这个选项好像只会让rocksdb自己使用jemalloc，主程序似乎仍然使用glibc malloc：<https://runsisi.com/2019/10/18/jemalloc-for-shared-lib/>

让整个程序使用tcmalloc或者jemalloc，最保险的方法是用`LD_PRELOAD`:

```shell
sudo apt install libtcmalloc-minimal4
LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4 程序 参数...

LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so 程序 参数...
```

也可以不用`LD_PRELOAD`，但好像不太通用：

<https://forums.gentoo.org/viewtopic-t-1056432-start-0.html>

<https://stackoverflow.com/questions/40915820/override-libc-functions-without-ld-preload>

#### peak RSS

RSS包含了shared library占用的空间。

#### total memory leaked

### 存在的问题

似乎跟tcmalloc不兼容。

```shell
LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4 heaptrack 命令 参数...
heaptrack_print xxx > report
```

会报错：

```text
Trace recursion detected - corrupt data file?
Trace recursion detected - corrupt data file?
```

而且`heaptrack*`文件特别小。应该是完全没有track到内存分配。

相关：<https://github.com/microsoft/mimalloc/issues/522>

## valgrind

`valgrind --tool=massif 你的程序 参数...`

能够知道哪些地方分配的内存最多。

文档：<https://valgrind.org/docs/manual/ms-manual.html>

但是valgrind会模拟出一个CPU来运行，所以运行速度会慢很多。

### `Illegal instruction`

可能是因为用到了本地CPU支持但是valgrind不支持的指令。调整编译选项使其编译出来的指令portable就行。

例如，rocksdb `cmake`的时候加上`-DPORTABLE=ON`即可。

参考：<https://wanghenshui.github.io/2019/06/02/valgrind-rocksdb.html>

## libtcmalloc

官方文档：<https://goog-perftools.sourceforge.net/doc/heap_profiler.html>

```shell
# Debian 11
# libtcmalloc.so
sudo apt install libgoogle-perftools-dev
# pprof-symbolize
sudo apt install google-perftools
```

```shell
mkdir profile
LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc.so" HEAPPROFILE=./profile/profile 程序 参数...
```

默认每申请1GB内存会生成一个这样的文件：

```text
<prefix>.0000.heap
<prefix>.0001.heap
<prefix>.0002.heap
...
```

分析一个heap文件：

```shell
google-pprof --text --lines 可执行文件的路径 profile.xxxx.heap
```

`--text`: 不进入interactive模式，而是直接打印报告。但是只打印内存消耗最多的地方，没有调用栈。如果加上`--stacks`，好像不会打印inline函数的调用栈，而且调用栈的打印顺序是随机的，不是按内存大小从大到小打印，看起来很难受。

`--svg`: 生成`svg`文件。里面有很漂亮的调用关系。

`--lines`: 输出行号

```text
   --add_lib=<file>    Read additional symbols and line info from the given library
```

会打印出内存消耗最多的地方。官方的例子（没有`--lines`，所以没有行号）：

```shell
   255.6  24.7%  24.7%    255.6  24.7% GFS_MasterChunk::AddServer
   184.6  17.8%  42.5%    298.8  28.8% GFS_MasterChunkTable::Create
   176.2  17.0%  59.5%    729.9  70.5% GFS_MasterChunkTable::UpdateState
   169.8  16.4%  75.9%    169.8  16.4% PendingClone::PendingClone
    76.3   7.4%  83.3%     76.3   7.4% __default_alloc_template::_S_chunk_alloc
    49.5   4.8%  88.0%     49.5   4.8% hashtable::resize
   ...
```

- The first column contains the direct memory use in MB.

- The fourth column contains memory use by the procedure and all of its callees.

- The second and fifth columns are just percentage representations of the numbers in the first and fourth（原文是fifth，应该是写错了） columns.

- The third column is a cumulative sum of the second column (i.e., the kth entry in the third column is the sum of the first k entries in the second column.)

跑得很慢。这里说libtcmalloc开了heap profiling之后会让程序慢5倍以上：<https://www.brendangregg.com/FlameGraphs/memoryflamegraphs.html>

## 没试过

### MTuner

<https://github.com/RudjiGames/MTuner>

看起来似乎不支持linux

### memleak

<https://github.com/iovisor/bcc>

<https://github.com/iovisor/bcc/blob/master/tools/memleak_example.txt>

好像只是打印一段时间没有被free的内存。
