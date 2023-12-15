---
title: perf.data生成火焰图
date: 2021-09-16 10:40:41
---

用perf或者别的东西生成perf.data后，可以用如下方法生成火焰图：

先把<https://github.com/brendangregg/FlameGraph.git> clone到目录`$FlameGraphPath`，然后

```shell
perf script -i perf.data > perf.unfold
$FlameGraphPath/stackcollapse-perf.pl perf.unfold > perf.folded
$FlameGraphPath/flamegraph.pl perf.folded > perf.svg
```

`perf.unfold`可能会比`perf.data`大将近十倍。如果磁盘放不下的话，可以直接pipe进`stackcollapse-perf.pl`:

```shell
perf script -i perf.data | $FlameGraphPath/stackcollapse-perf.pl > perf.folded
```

原文：<https://www.cnblogs.com/lausaa/p/12098716.html>
