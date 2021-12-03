---
title: rust atoi
date: 2021-12-03 21:06:44
tags:
---

rust标准库里没有```atoi```。要将字符串转为整数，可以用```parse```：

```rs
fn main() {
    let s = "23333";
    let x: usize = s.parse().unwrap();
    println!("{}", x);
}
```

```
23333
```
