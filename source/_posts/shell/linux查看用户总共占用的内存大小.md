---
title: linux查看用户总共占用的内存大小
date: 2022-04-10 15:46:35
tags:
---

查看当前用户总共占用的内存大小：

```shell
smem -u
```

查看所有用户总共占用的内存大小：

```shell
sudo smem -u
```

USS、PSS、RSS的含义：[Linux：VSS、RSS、PSS和USS的图解说明](https://blog.csdn.net/whbing1471/article/details/105523704)

来源：<https://serverfault.com/a/31031>
