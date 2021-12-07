---
title: ubuntu cargo flamegraph
date: 2021-08-12 13:43:30
---

```shell
cargo flamegraph
```

有如下选项：

# 运行指定binnary

```shell
-b your-binnary
```

# 指定采样频率

```shell
-F xxx
```

单位好像是Hz

# 传参

```shell
-- your-arg your-value
```

# 传入perf参数

```
-c "要给perf的参数
```

比如

```shell
cargo flamegraph -c "record -e branch-misses -c 100 --call-graph lbr -g"
```

# 例子

```shell
cargo flamegraph -F 1 --bin transaction-replayer -- --perf-log data/perf-log.txt
```

```shell
cargo flamegraph -c "recor
d -a -F 1 --call-graph=dwarf" --bin transaction-replayer -- --start-epoch 18000000 --epoch-to-execute 1000000 --commit-interval 10000
```

注意用了```-c```时，```-F 1```要放到```-c```后面的perf参数里。

# 常见错误的处理

```
could not spawn perf
```

```shell
sudo apt install linux-tools-common
```

```
WARNING: perf not found for kernel 4.15.0-144

  You may need to install the following packages for this specific kernel:
    linux-tools-4.15.0-144-generic
    linux-cloud-tools-4.15.0-144-generic

  You may also want to install one of the following packages to keep up to date:
    linux-tools-generic
    linux-cloud-tools-generic
failed to sample program
```

按照提示安装即可：

```shell
sudo apt install linux-tools-4.15.0-144-generic linux-cloud-tools-4.15.0-144-generic linux-tools-generic linux-cloud-tools-generic
```


# 参考文献
[ubuntu18.04安装perf](https://blog.csdn.net/qq_36974075/article/details/82491219)
<https://github.com/brendangregg/FlameGraph/issues/209>
<https://github.com/flamegraph-rs/flamegraph>
