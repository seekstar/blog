---
title: 被锁保护的变量不需要使用volatile
date: 2020-12-01 09:59:28
---

<https://stackoverflow.com/questions/6837699/are-mutex-lock-functions-sufficient-without-volatile>
因为进行函数调用的时候，编译器不知道它会不会修改全局变量，所以就防止了这个共享变量被放到寄存器中？
