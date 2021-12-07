---
title: rust从一行中读取数组
date: 2020-08-26 13:50:41
tags:
---

```rust
use std::io;

fn main() {
    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();
    let ns: Vec<i32> = input.trim().split(' ').map(|x| x.parse().unwrap()).collect();
    for v in ns {
        print!("{} ", v);
    }
}
```

输入：

```
3 2 1 1 2 3
```

输出：

```
3 2 1 1 2 3
```
