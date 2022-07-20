---
title: ctrl+c杀死脚本中的timeout命令
date: 2022-07-20 17:45:15
tags:
---

`timeout`命令默认运行在单独的进程组中，而终端的`ctrl+c`的SIGINT信号只发送给脚本，timeout命令接收不到。想让timeout命令接收到终端的`ctrl+c`发送的SIGINT的信号，需要加上参数`--foreground`，这样timeout命令就会继承父进程的进程组。例子：

```shell
timeout --foreground 1h sleep 1m
```

来源：<https://stackoverflow.com/questions/67997060/bash-script-run-with-timeout-wont-exit-on-sigint>
