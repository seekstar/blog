---
title: 解决shell脚本中kill -2对后台进程不起作用
date: 2021-10-04 23:04:07
---

# 问题

`kill -2`就是发送SIGINT信号。我们期望的行为是，进程接收到SIGINT信号后就停止运行。例如：

```shell
yes >/dev/null &
pid=$!
echo $pid
sleep 2
kill -INT $pid
sleep 2
ps aux | grep yes
```

将其保存为`kill.sh`，让其直接在当前交互式shell里执行：

```shell
source kill.sh
```

结果：

```
21505
[1]+  中断                  yes > /dev/null
searchs+ 21520  0.0  0.0   9168   888 pts/2    S+   22:12   0:00 grep yes
```

可以看到这个后台进程被顺利中断了。但是如果用bash执行它：

```shell
bash kill.sh
```

```
21981
searchs+ 21981  100  0.0   8340   748 pts/2    R+   22:14   0:04 yes
searchs+ 21990  0.0  0.0   9168   892 pts/2    S+   22:14   0:00 grep yes
```

这时就没有被中断。

# 原因

在交互式shell中，有job control，ctrl+c是发送给前台进程组的，而后台进程是在后台进程组中的，因此不会受到ctrl+c的影响，所以沿用了SIGINT默认的信号处理，即直接终止进程。

但是，在非交互式shell中，默认是没有job control的，即所有子进程，无论是前台进程还是后台进程，都跟shell在同一个进程组中。为了防止对这个shell进程发送SIGINT的时候把后台进程给一起杀掉了，在创建后台子进程时会默认将SIGINT忽略掉。不过如果后台子进程自己安装了SIGINT的处理函数，向其发送SIGINT仍然会起作用。

# 解决方法

在shell脚本的开头加上`set -m`，使其进入monitor mode，这样可以开启job control，从而使得生成的后台子进程默认不忽略SIGINT。

# 参考文献

<https://unix.stackexchange.com/questions/372541/why-doesnt-sigint-work-on-a-background-process-in-a-script>
<https://stackoverflow.com/questions/45106725/why-do-shells-ignore-sigint-and-sigquit-in-backgrounded-processes>
