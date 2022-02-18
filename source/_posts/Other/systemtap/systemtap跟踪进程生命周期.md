---
title: systemtap跟踪进程生命周期
date: 2020-12-27 19:16:05
---

systemtap man: <https://sourceware.org/systemtap/man/>
本来追踪进程生命周期可以用syscall.fork和syscall.exit之类的。但是有时候它们会失效（或者部分失效）。
所以更好的方式是用`kprocess`系列，文档：<https://sourceware.org/systemtap/man/tapset::kprocess.3stap.html>
`kprocess.create`的上下文应该是刚刚fork成功的父进程。
`kprocess.start`的上下文应该是刚刚被fork出来的子进程。
`kprocess.exec`的上下文是exec的调用者，此时execname仍然是原来的。
`kprocess.exec_complete`的上下文是exec执行完毕，此时execname已经改变了。
`kprocess.exit`的上下文是exit的调用者。
`kprocess.release`的上下文文档里这么说的：

```text
The context of the parent, if it wanted notification of this process' termination, else the context of the process itself.  
```
