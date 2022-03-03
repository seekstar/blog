---
title: YCSB生成trace
date: 2022-03-03 17:45:02
tags:
---

有两种方法，一种是自己写一个伪造的client，然后把get和update之类的操作全部截下来打印到文件里去：<https://github.com/seekstar/kvtracer>

另一种是用YCSB自带的`BasicDB`，实现代码：<https://github.com/brianfrankcooper/YCSB/blob/master/core/src/main/java/site/ycsb/BasicDB.java>

用法：

```shell
bin/ycsb load basic -P workloads/workloada > tracea_load_basic.txt
bin/ycsb run basic -P workloads/workloada > tracea_run_basic.txt
```

然后load和run部分的trace就分别在`tracea_load_basic.txt`和`tracea_run_basic.txt`中了。
