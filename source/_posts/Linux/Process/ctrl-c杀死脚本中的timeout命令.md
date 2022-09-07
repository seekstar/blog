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

## 奇怪的是

SIGINT应该是会发送给脚本的，因此预期行为应该是脚本被杀死了，而timeout进程变成了孤儿进程。但是实际上脚本似乎被timeout进程给阻塞了，要在timeout命令结束之后才会接收SIGINT信号，原因不明。
