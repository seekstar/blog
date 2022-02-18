---
title: hexo查找失效的post_link
date: 2022-02-18 15:34:14
tags:
---

把部署的网站clone下来，比如我的是：

```shell
git clone https://github.com/seekstar/seekstar.github.io
```

然后直接在这里面字符串查找```Post Not Fount```，就能发现失效的post_link了。

例如我的：

```shell
grep -rn "Post not found"
```

```text
page/2/index.html:5657:Post not found: Linux/Debian-11-安装SPDK
tags/RocksDB/index.html:5612:Post not found: Linux/Debian-11-安装SPDK
archives/page/2/index.html:5657:Post not found: Linux/Debian-11-安装SPDK
archives/2022/01/index.html:5657:Post not found: Linux/Debian-11-安装SPDK
archives/2022/page/2/index.html:5657:Post not found: Linux/Debian-11-安装SPDK
2022/01/23/spandb运行ycsb测试/index.html:5640:<a href="#">Post not found: Linux/Debian-11-安装SPDK</a>
```
