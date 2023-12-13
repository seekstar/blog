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

以`ls`为例：

```shell
mkdir ~/profile
LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc.so" HEAPPROFILE=$HOME/profile/profile ls
cd ~/profile
google-pprof --text /usr/bin/ls profile.0001.heap
```

然后就会打印出内存消耗最多的地方：

```shell
Starting tracking the heap
Using local file /usr/bin/ls.
Using local file profile.0001.heap.
Total: 0.0 MB
     0.0  68.1%  68.1%      0.0 100.0% _obstack_begin
     0.0  11.6%  79.8%      0.0  11.6% _nl_make_l10nflist
     0.0   9.7%  89.5%      0.0   9.7% _nl_intern_locale_data
     0.0   5.3%  94.9%      0.0   5.3% read_alias_file
     0.0   4.2%  99.0%      0.0   4.2% extend_alias_table
     0.0   0.3%  99.4%      0.0   0.3% _obstack_memory_used
     0.0   0.3%  99.6%      0.0   0.3% __GI___strdup
     0.0   0.3%  99.9%      0.0   0.3% __GI___strndup
     0.0   0.1% 100.0%      0.0   0.1% set_binding_values
     0.0   0.0% 100.0%      0.0   0.0% new_composite_name
     0.0   0.0% 100.0%      0.0  31.4% __GI_setlocale
     0.0   0.0% 100.0%      0.0 100.0% __libc_start_main@@GLIBC_2.2.5
     0.0   0.0% 100.0%      0.0   0.0% __textdomain
     0.0   0.0% 100.0%      0.0   9.5% _nl_expand_alias
     0.0   0.0% 100.0%      0.0  31.1% _nl_find_locale
     0.0   0.0% 100.0%      0.0   9.7% _nl_load_locale
```

`google-pprof`的一些选项：

`--text`: 不进入interactive模式，而是直接打印报告。

```text
   --add_lib=<file>    Read additional symbols and line info from the given library
```

但是没有行号。而且跑得很慢。这里说libtcmalloc开了heap profiling之后会让程序慢5倍以上：<https://www.brendangregg.com/FlameGraphs/memoryflamegraphs.html>

## 没试过

### MTuner

<https://github.com/RudjiGames/MTuner>

看起来似乎不支持linux

### memleak

<https://github.com/iovisor/bcc>

<https://github.com/iovisor/bcc/blob/master/tools/memleak_example.txt>

好像只是打印一段时间没有被free的内存。
