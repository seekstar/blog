---
title: "rust note: `#[warn(dead_code)]` on by default"
date: 2021-07-19 19:13:26
---

如果要允许未使用的代码，在前面加上
```rust
#[allow(dead_code)]
```
即可。

参考文献：
<https://doc.rust-lang.org/rust-by-example/attribute/unused.html>
