---
title: rust用BufReader加速stdin读取
date: 2021-11-17 17:30:21
tags:
---

BufReader官方文档：<https://doc.rust-lang.org/stable/std/io/struct.BufReader.html>

```rust
use std::io::{self, BufRead, BufReader};

let mut cin = BufReader::new(io::stdin());
// cin.read_line
```

注意用了`BufReader`来优化stdin读取之后，一定就不能再用`io::stdin()`来直接读取了，不然会乱套。
