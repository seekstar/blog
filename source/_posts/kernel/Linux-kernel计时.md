---
title: Linux kernel计时
date: 2022-12-02 16:38:09
tags:
---

可以用`getrawmonotonic`来获取当前时间，两个时间点相减就是中间经过的时间了：

```c
#include <linux/time.h>

static uint64_t get_cur_nsec(void) {
    struct timespec time;
    getrawmonotonic(&time);
    return (uint64_t)time.tv_sec * 1000000000 + time.tv_nsec;
}
```
