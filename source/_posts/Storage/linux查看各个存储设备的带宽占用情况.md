---
title: linux查看各个存储设备的带宽占用情况
date: 2022-05-05 12:18:51
tags:
---

用`iostat`可以查看各个存储设备的读写带宽占用情况。

注意单独的一个`iostat`命令的输出是不准的，因为采样窗口太短了。正确的使用方法如下：

```shell
# 每隔一秒钟打印一次过去的一秒钟里的I/O情况
iostat 1
# 收集一秒钟内的I/O情况，然后打印出来。第二个参数的含义是打印两次，只有第二次的才是准确的。
iostat 1 2
```

如果要看某个device有没有saturated，可以`iostat 1 -x`，其中`-x`的含义是`Display extended statistics.`。

打印出来的`%util`列就是utilization，红了表示saturated。

来源：<https://www.percona.com/blog/looking-disk-utilization-and-saturation/>
