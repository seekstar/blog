---
title: Memcached学习笔记
date: 2024-04-04 12:14:40
tags:
---

官方文档：<https://github.com/memcached/memcached/wiki>

API: <https://github.com/memcached/memcached/wiki/Commands>

文档里没有讲清楚`gets`是干嘛的。`get`只返回value，而`gets`不仅返回value，还返回这个value对应的`cas_token`，可以理解成版本号。之后这个`cas_token`作为`cas`操作的参数，如果在`gets`之后值更新了，`cas`操作就会失败，可以理解成`cas`操作对比了当前版本号和参数里的版本号，如果变更了就不更新。

参考：

<https://www.dragonflydb.io/code-examples/node-memcached-gets>

<https://www.php.net/manual/en/memcached.cas.php>
