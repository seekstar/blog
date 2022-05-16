---
title: soft lockup时在console打印stack
date: 2022-05-16 10:49:56
tags:
---

有时soft lockup之后整台机器就没有响应了，在console不断有这些消息被打印出来：

```text
[  492.400124] watchdog: BUG: soft lockup - CPU#5 stuck for 22s!
```

但是并没有打印出stack，导致不知道在哪里stuck住了。注意到如果是panic的话stack就会在console被打印出来。所以如果要让soft lockup时在console打印stack，可以设置为在soft lockup时panic：

```shell
echo 1 > /proc/sys/kernel/softlockup_panic
```

参考：<https://askubuntu.com/questions/725403/capturing-a-kernel-dump-from-a-cpu-soft-lockup-at-boot>
