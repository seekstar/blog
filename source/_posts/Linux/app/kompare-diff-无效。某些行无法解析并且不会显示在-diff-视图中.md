---
title: kompare diff 无效。某些行无法解析并且不会显示在 diff 视图中
date: 2021-12-30 21:49:46
tags:
---

kompare是diff的前端。所以可能是因为一些文件是二进制文件，然后diff不能处理二进制文件？

可以试试meld，对比两个目录：

```shell
meld dir1 dir2
```
