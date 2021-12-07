---
title: perf.data生成火焰图
date: 2021-09-16 10:40:41
---

用perf或者别的东西生成perf.data后，可以用如下方法生成火焰图：

先把<https://github.com/brendangregg/FlameGraph.git> clone到某个目录，然后

```shell
perf script -i perf.data > perf.unfold
/path/to/FlameGraph/stackcollapse-perf.pl perf.unfold > perf.folded
/path/to/FlameGraph/flamegraph.pl perf.folded > perf.svg
```

原文：<https://www.cnblogs.com/lausaa/p/12098716.html>
