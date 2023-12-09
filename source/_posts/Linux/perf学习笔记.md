---
title: perf学习笔记
date: 2023-12-08 19:06:53
tags:
---

官方文档：<https://perf.wiki.kernel.org/index.php/Main_Page>

简单用法：

```shell
perf record 命令 参数...
```

会生成perf.data，可以用来生成火焰图： {% post_link Linux/'perf.data生成火焰图' %}

注意所有代码（包括系统库）都要`-fno-omit-frame-pointer`来编译，不然生成的火焰图调用关系是错的。具体方法请参考：{% post_link Linux/'linux perf得到完整调用关系' %}
