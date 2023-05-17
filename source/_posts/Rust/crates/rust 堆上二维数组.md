---
title: rust 堆上二维数组
date: 2021-09-15 16:56:00
---

用ndarray: 

<https://docs.rs/ndarray/0.15.3/ndarray/>
[Rust 多维数组 ndarray](https://blog.csdn.net/wsp_1138886114/article/details/108635600)

例子：

```rust
use ndarray::Array2;

fn main() {
    let mut a = Array2::<usize>::zeros((2, 3));
    println!("{:?}", a.dim());
    for i in 0..2 {
        for j in 0..3 {
            a[[i, j]] = i + j;
        }
    }
    for i in 0..a.dim().0 {
        for j in 0..a.dim().1 {
            print!("{}", a[[i, j]]);
        }
        print!("\n");
    }
}
```
