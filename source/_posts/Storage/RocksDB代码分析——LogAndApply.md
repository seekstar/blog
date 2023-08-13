---
title: RocksDB代码分析——LogAndApply
date: 2023-08-09 16:25:48
tags:
---

这里我们主要分析`VersionSet::LogAndApply`是怎么管理writer队列的。

参数里的`edit_lists`是需要被apply的改动。每个传入的column family data对应`edit_lists`里的一个edit list，即`autovector<VersionEdit*>`。

接下来把每个edit list打包成一个`ManifestWriter`，放进`std::deque<ManifestWriter> writers`里。此外，由于对manifest的修改必须逐个进行，因此`VersionSet`里还维护了一个`MenifestWriter`的队列：`manifest_writers_`。因此还需要把打包好的`ManifestWriter`的指针放进`manifest_writers_`里。

然后把要执行的第一个writer拿出来：`ManifestWriter& first_writer = writers.front();`

等待它成为队首或者完成：

```cpp
  while (!first_writer.done && &first_writer != manifest_writers_.front()) {
    first_writer.cv.Wait();
  }
```

如果它完成了，由于我们是一次性把所有writer都推入队列的，说明其他的也完成了，所以可以直接返回：

```cpp
  if (first_writer.done) {
    return first_writer.status;
  }
```

否则它就是队首。

由于我们是持有了DB mutex的，因此`writers`中的`ManifestWriter`在队列`manifest_writers_`中也是贴在一起的。这样，如果writers中的第一个writer变成了队列的队首，那么`writers`中其他的writer就紧贴其后，这样我们就可以正式开始逐个执行这些writer了。

进入`VersionSet::ProcessManifestWrites`。

然后逐个去执行队列`manifest_writers_`里的writer，`last_writer`是最后一个被执行了的writer。

然后后面又有一大堆操作，具体没看，但是其中会释放并重新申请DB mutex。因此到这个函数的末尾时，`writers`里的所有writer肯定都已经执行完毕了，但是`last_writer`不一定是队列`manifest_writers_`里的最后一个writer。

```cpp
  while (true) {
    // 遍历已经执行完成的writer
    ManifestWriter* ready = manifest_writers_.front();
    manifest_writers_.pop_front();
    bool need_signal = true;
    // 如果它在writers里，就不用发信号了，因为它们都归我们管
    // 如果它不在writers里，说明可能有另一个线程在等待它变成队首，这时就要发信号
    for (const auto& w : writers) {
      if (&w == ready) {
        need_signal = false;
        break;
      }
    }
    ready->status = s;
    ready->done = true;
    if (ready->manifest_write_callback) {
      (ready->manifest_write_callback)(s);
    }
    if (need_signal) {
      ready->cv.Signal();
    }
    if (ready == last_writer) {
      break;
    }
  }
  // 因为last_writer不一定是manifest_writers_里的最后一个，所以给新的队首发送信号。
  if (!manifest_writers_.empty()) {
    manifest_writers_.front()->cv.Signal();
  }
```

但我有一个问题，在等待`first_writer`变成队首的时候，并没有unlock DB mutex，而后面给新队首发信号的时候也是hold DB mutex的，那这两者应该不能同时发生才对。
