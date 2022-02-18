---
title: linux perf得到完整调用关系
date: 2021-09-20 10:38:42
---

一般情况下，在高优化等级时，编译器会把栈帧破坏掉，导致生成的火焰图调用关系是错误的。即使自己的代码用了`-fno-omit-frame-pointer`来编译，从而使得自己的代码不破坏栈帧，库的代码可能仍然会破坏栈帧。这时就应该使用linux perf的`--call-graph=dwarf`，这样perf会把一部分栈内存保存下来，然后通过后处理来unwind，从而得到完整的调用栈。但是这会导致采样的时间开销和空间开销增大，所以采样频率可能要稍微调低一点。

参考文献：

<https://users.rust-lang.org/t/opt-level-2-removes-debug-symbols-needed-in-perf-profiling/16835/7>
<https://stackoverflow.com/questions/57430338/what-do-the-perf-record-choices-of-lbr-vs-dwarf-vs-fp-do>
