---
title: Linux杀死所有子进程
date: 2022-06-08 21:49:51
tags:
---

杀死某一进程的所有子进程：

```shell
pkill -P <PID>
```

杀死当前进程的所有子进程：

```shell
pkill -P $$
```

如果要在脚本退出前杀死所有子进程，只需要：

```shell
trap "pkill -P $$" EXIT
```

但是有时候子进程又会fork出自己的子进程，如果要把这种后代进程也全部杀死，可以这样：

```shell
trap "kill -TERM -$$" EXIT
```

参考：

<https://unix.stackexchange.com/questions/124127/kill-all-descendant-processes>

[Linux shell 如何捕获信号(trap命令)](https://blog.csdn.net/chen1415886044/article/details/103301121)

{% post_link Linux/Process/'Linux-shell向进程组发信号' %}
