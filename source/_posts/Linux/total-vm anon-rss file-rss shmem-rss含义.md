---
title: total-vm anon-rss file-rss shmem-rss含义
date: 2021-07-28 14:44:31
---

进程被杀了。查一下日志：

```shell
dmesg | egrep -i -B100 'killed process'
```

```
[2352218.368085] Out of memory: Kill process 1462 (transaction-exp) score 834 or sacrifice child
[2352218.368850] Killed process 1462 (transaction-exp) total-vm:18307836kB, anon-rss:13871180kB, file-rss:316kB, shmem-rss:0kB
```

```total-vm```: total virtual memory. 进程使用的总的虚拟内存。
```rss```: resident set size. 驻留集大小。驻留集是指进程已装入内存的页面的集合。
```anon-rss```: anonymous rss. 匿名驻留集。比如malloc出来的就是匿名的。
```file-rss```: 映射到设备和文件上的内存页面。
```shmem-rss```: 大概是shared memory rss? 

参考文献
<https://stackoverflow.com/questions/18845857/what-does-anon-rss-and-total-vm-mean>
[操作系统---(39)驻留集，工作集与抖动的预防](https://blog.csdn.net/qq_43101637/article/details/106672208)
