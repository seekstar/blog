---
title: rust踩坑笔记
date: 2021-09-29 15:54:29
---

# mpsc

需求：需要在一个线程里读取数据，发送给另一个线程处理。

我的方法：用mpsc的channel发送和接收。

坑：mpsc的channel从不阻塞发送方，它有无限的缓冲。结果读取远远比写入快，导致大量内存被消耗。

解决方案：用```sync_channel```：

```rs
pub fn sync_channel<T>(bound: usize) -> (SyncSender<T>, Receiver<T>)
```

这个bound参数应该指的是个数。

文档：<https://doc.rust-lang.org/stable/std/sync/mpsc/index.html>
