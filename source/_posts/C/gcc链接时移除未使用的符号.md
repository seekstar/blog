---
title: gcc链接时移除未使用的符号
date: 2020-08-03 13:02:52
tags:
---

参考：
<https://www.cnblogs.com/dylancao/p/10668549.html>
<https://kb.kutu66.com/function/post_6611676>

```shell
gcc -Wl,--gc-sections,--print-gc-sections main.o add.o -o main
```
可以用
```shell
objdump -D main | less
```
来查看最终的可执行文件中是否还有未使用的符号。
