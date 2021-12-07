---
title: rust unresolved import `minigrep`
date: 2021-05-14 16:32:56
---

rust ```The book```练习题minigrep:
<https://doc.rust-lang.org/book/ch12-03-improving-error-handling-and-modularity.html>
```shell
cargo run
```
报错：```unresolved import `minigrep```。
原因是把```lib.rs```命名成```run.rs```了。改回```lib.rs```就好了。这说明```lib.rs```的名字是有特殊含义的。
