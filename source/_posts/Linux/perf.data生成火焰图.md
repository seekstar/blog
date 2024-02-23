---
title: perf.data生成火焰图
date: 2021-09-16 10:40:41
---

用perf或者别的东西生成perf.data后，可以用如下方法生成火焰图：

先把<https://github.com/brendangregg/FlameGraph.git> clone到目录`$FlameGraphPath`，然后

```shell
perf script -i perf.data > perf.unfold
$FlameGraphPath/stackcollapse-perf.pl perf.unfold > perf.folded
```

`perf.unfold`可能会比`perf.data`大将近十倍。所以一般是直接pipe进`stackcollapse-perf.pl`:

```shell
perf script -i perf.data | $FlameGraphPath/stackcollapse-perf.pl > perf.folded
$FlameGraphPath/flamegraph.pl perf.folded > perf.svg
```

注意，解析`perf.data`的时候好像要读取binary里的符号，所以在解析的时候不要重新编译之类的。

如果嫌perl写的`stackcollapse-perf.pl`太慢的话，可以尝试rust写的`inferno`: <https://docs.rs/inferno/latest/inferno/>

```shell
cargo install inferno
perf script -i perf.data | inferno-collapse-perf > perf.folded
# 默认太宽了。perl版本的宽度是1200，所以这里也设置成1200
inferno-flamegraph --width=1200 < perf.folded > perf.svg
```

实测比perl版本快大约4倍。不过生成的`perf.svg`字太小了。可以用`inferno`生成`perf.folded`，再用`flamegraph.pl`来画火焰图：

```shell
cargo install inferno
perf script -i perf.data | inferno-collapse-perf > perf.folded
$FlameGraphPath/flamegraph.pl perf.folded > perf.svg
```

## 参考文献

[linux 性能分析工具 perf + FlameGraph](https://www.cnblogs.com/lausaa/p/12098716.html)
