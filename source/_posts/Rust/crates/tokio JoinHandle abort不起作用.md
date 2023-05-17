---
title: tokio JoinHandle abort不起作用
date: 2021-08-25 17:36:59
---

可能是因为这个线程在一个没有await的死循环里？

参考：<https://users.rust-lang.org/t/abort-asynchronous-task/61961>
