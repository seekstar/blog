---
title: gdb学习笔记
date: 2023-10-27 16:30:12
tags:
---

运行带参数的程序：

```shell
gdb --args executablename arg1 arg2 arg3
```

来源：<https://stackoverflow.com/questions/6121094/how-do-i-run-a-program-with-commandline-arguments-using-gdb-within-a-bash-script>

attach到正在运行的进程：

```shell
gdb --pid xxx
```

## list / l

打印当前正在运行的位置附近的代码

## print / p

打印变量的值

## backtrace / bt

打印调用栈。

例子：

```text
(gdb) backtrace
#0  __pthread_clockjoin_ex (threadid=140512052778752, thread_return=0x0, clockid=<optimized out>, 
    abstime=<optimized out>, block=<optimized out>) at pthread_join_common.c:145
#1  0x00007fcb96c5c0e3 in std::thread::join() () from /lib/x86_64-linux-gnu/libstdc++.so.6
#2  0x000055d5daf78905 in Tester::Test (this=this@entry=0x7ffe1974a070) at /home/searchstar/kvexe/src/test.hpp:314
#3  0x000055d5daf5e78a in main (argc=<optimized out>, argv=<optimized out>)
    at /home/searchstar/kvexe/src/main.cpp:598
```

## frame / f

选择backtrace里的某一项。例如要选择上面的例子中的：

```text
#2  0x000055d5daf78905 in Tester::Test (this=this@entry=0x7ffe1974a070) at /home/searchstar/kvexe/src/test.hpp:314
```

就`f 2`

## `info threads`

打印每个线程执行到了什么地方

## `thread apply`

在指定线程中执行命令。

例子：`thread apply all bt`，在所有线程中执行`bt`，即打印所有线程的调用栈。

## 参考文献

<https://sourceware.org/gdb/download/onlinedocs/gdb/Threads.html>
