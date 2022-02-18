---
title: hexo查找失效的post_link
date: 2022-02-18 15:34:14
tags:
---

先`hexo d -g`，然后新的网站就会生成在`.deploy_git`下面，进去这个目录，在这里面用`grep`之类的查找`Post Not Fount`，就能发现失效的post_link了。

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
