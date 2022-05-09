---
title: golang手动触发GC
date: 2022-05-09 15:06:41
tags:
---

```go
import "runtime"

runtime.GC()
```

来源：[Golang什么时候会触发GC](https://www.jianshu.com/p/96a52a8127d9)
