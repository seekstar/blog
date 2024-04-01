---
title: Linux控制进程CPU使用率
date: 2024-04-01 15:21:53
tags:
---

使用`cpulimit`不用root权限也能控制CPU使用率：<https://github.com/opsengine/cpulimit>

例如要控制最多使用200%的CPU，也就是两个核：

```shell
cpulimit -l 200 -f -- 可执行文件 参数...
```

```text
       -l, --limit=N
              percentage of CPU allowed from 1 up. Usually 1 - 100, but can be higher on multi-core CPUs. (manda‐
              tory)
       -f, --foreground
              run cpulimit in foreground while waiting for launched process to finish
```

