---
title: systemtap原理
date: 2020-12-26 22:52:47
---

systemtap的核心是probe（探针），可以在任何一条语句上加上探针，当执行到这条语句时将控制流转移到探针的handler上。其实现原理是在module_init时将相应指令的第一个字节替换成0xcc，也就是INT 3。这样执行到这条指令时就会跳转到INT 3的中断处理函数，由其判断出应该跳转到哪个handler。在module_exit中将这些指令还原。
