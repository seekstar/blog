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

## 没试过

<https://github.com/RudjiGames/MTuner>

<https://doordash.engineering/2021/04/01/examining-problematic-memory-with-bpf-perf-and-memcheck/>

<https://www.brendangregg.com/FlameGraphs/memoryflamegraphs.html>
