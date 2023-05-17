---
title: rust print固定宽度左边补零
date: 2020-08-25 19:34:43
tags:
---

参考：<https://doc.rust-lang.org/std/fmt/>

```rust
fn main() {
    println!("{:0>3}", 2333);
    println!("{:0>3}", 233);
    println!("{:0>3}", 23);
    println!("{:0>3}", 2);
    println!("{:0>3}", 0);
    println!("{:0>3}", -2);
}
```
其中`>`表示向右对齐，`0`是在左边补的字符。
```
2333
233
023
002
000
0-2
```
