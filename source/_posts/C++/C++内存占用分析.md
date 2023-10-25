---
title: C++内存占用分析
date: 2023-10-25 20:43:07
tags:
---

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

但是还是跑得很慢，而且没有行号。

## 没试过

<https://github.com/RudjiGames/MTuner>

<https://doordash.engineering/2021/04/01/examining-problematic-memory-with-bpf-perf-and-memcheck/>

<https://www.brendangregg.com/FlameGraphs/memoryflamegraphs.html>
