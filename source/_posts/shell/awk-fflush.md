---
title: awk fflush
date: 2022-06-08 20:20:47
tags:
---

awk如果检测到stdout不是直接输出到终端的话，会对输出做buffering，因此如果是周期性连续数据，而且需要把stdout重定向给另一个命令的stdin，那么需要`fflush(stdout)`：

```shell
iostat 1 | awk '{print $1; fflush(stdout)}' | grep sda
```

不然`awk`的输出会被缓存住，`grep`会长时间收不到输入，从而导致终端很长一段时间都没有打印出东西。

同理，`grep`如果检测到stdout不是直接输出到终端的话，也会对输出做buffering，因此需要加上`--line-buffered`，让`grep`按行来buffer而不是按size来buffer，这样就可以保证每行都可以及时输出到下一个命令：

```shell
iostat 1 | grep --line-buffered sda | awk '{print $2,$3,$4}'
```

参考：

<https://superuser.com/questions/379122/how-to-pipe-awk-output-with-periodic-continuous-input-to-output-file>

<https://superuser.com/questions/909686/grep-and-sed-with-pipe-from-tail-f-appears-to-be-caching>
