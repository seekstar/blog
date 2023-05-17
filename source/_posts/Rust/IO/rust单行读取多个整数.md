---
title: rust单行读取多个整数
date: 2020-08-15 10:49:13
tags:
---

rust读取真的很麻烦。网上的方法一般是用split(' ')来分割出整数。但是如果中间有多个空格就凉了。后面查阅官方文档发现了split_whitespace，可以用多个空白字符（空格和tab，不含换行符）分割。

```rust
use std::io;

fn main() {
    let mut input=String::new();
    io::stdin().read_line(&mut input).unwrap();
    let mut s = input.split_whitespace();
    let a: i32 = s.next().unwrap().parse().unwrap();
    let b: i32 = s.next().unwrap().parse().unwrap();
    println!("{}", a + b);
}
```

输入：

```
  111    222   
```

注意，222后面有空格。

输出：

```
333
```
