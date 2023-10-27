---
title: C++内存占用分析
date: 2023-10-25 20:43:07
tags:
---

## heaptrack

可以打印出消耗内存最多的地方、申请内存次数最多的地方、临时申请内存最多的地方。

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

- `MOST CALLS TO ALLOCATION FUNCTIONS`
- `PEAK MEMORY CONSUMERS`
- `MOST TEMPORARY ALLOCATIONS`
- 最后的summary

运行速度差不多是正常运行的三四倍。输出的trace虽然经过了压缩，但还是很大。

## valgrind

`valgrind --tools=massif 你的程序 参数...`

能够知道哪些地方分配的内存最多。

文档：<https://valgrind.org/docs/manual/ms-manual.html>

但是valgrind会模拟出一个CPU来运行，所以运行速度会慢很多。

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
