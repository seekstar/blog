---
title: bash查询某文件的绝对路径
date: 2020-06-05 15:13:47
tags:
---

用`realpath`即可。

```shell
searchstar@searchstar-PC:/tmp/test$ ls
chroot  test2.sh  test3.sh  test4.sh  test5.sh  test.sh
searchstar@searchstar-PC:/tmp/test$ realpath test3.sh 
/tmp/test/test3.sh
```
