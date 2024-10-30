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

`add-symbol-file`: <https://stackoverflow.com/questions/30281766/need-to-load-debugging-symbols-for-shared-library-in-gdb>

## list / l

打印当前正在运行的位置附近的代码

## print / p

打印变量的值：

```text
p 变量
```

以数组的方式打印指针：

```text
p *array@len
```

用16进制打印：

```text
p/x *array@len
```

来源：<https://stackoverflow.com/a/64055978>

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

## `thread`

切换到`info threads`里的某一个thread。例如要选择这个thread：

```text
  10   Thread 0x7f199dffb700 (LWP 1530942) "checker"       __lll_lock_wait (futex=futex@entry=0x55aea2384ea8, 
    private=0) at lowlevellock.c:52
```

就输入`thread 10`

## 断点

官方文档：<https://sourceware.org/gdb/current/onlinedocs/gdb.html/Set-Breaks.html#Set-Breaks>

设置断点：`break` / `b`

默认在当前行设置断点。后面也可以加断点的具体位置。

删除所有断点：`clear`

## `-ex gdb命令`

执行一条gdb命令。比如让gdb立即执行命令：`gdb -ex run --args 命令 参数...`

来源：<https://stackoverflow.com/questions/2119564/how-to-automatically-run-the-executable-in-gdb>

如果还需要让命令正常退出时gdb也退出，但是命令异常时暂停：

```shell
gdb -ex='set confirm on' -ex='set pagination off' -ex=run -ex=quit --args 命令 参数...
```

来源：<https://stackoverflow.com/a/8657833>

## core dump

系统可能默认禁用了core dump:

```shell
ulimit -c
```

返回0说明不允许core dump。要启用core dump，可以在当前shell里把它设置成unlimited:

```shell
ulimit -c unlimited
```

然后在同一个shell里运行程序时再出现segfault就会dump core。

然后就可以用gdb来解析这个core file:

```shell
gdb executable core-file
```

来源：<https://www.bogotobogo.com/cplusplus/debugging_core_memory_dump_segmentation_fault_gdb.php>

## 参考文献

<https://sourceware.org/gdb/download/onlinedocs/gdb/Threads.html>
