---
title: rust交换两个引用
date: 2021-10-19 18:53:46
---

```rust
fn main() {
    let x = 1;
    let y = 2;
    let mut xx = &x;
    let mut yy = &y;
    println!("{} {}", xx, yy);
    let tmp = xx;
    xx = yy;
    yy = tmp;
    println!("{} {}", xx, yy);
}
```

```
1 2
2 1
```

这样是可以的。但是如果是在函数里交换传进来的两个引用：

```rust
fn foo(x: &i32, y: &i32) {
    let tmp = x;
    x = y;
    y = tmp;
    println!("{} {}", x, y);
}

fn main() {
    let x = 1;
    let y = 2;
    foo(&x, &y);
}
```

就会报lifetime有关的错误：

```
error[E0623]: lifetime mismatch
 --> learn_swap_two_references.rs:4:9
  |
1 | fn foo(mut x: &i32, mut y: &i32) {
  |               ----         ----
  |               |
  |               these two types are declared with different lifetimes...
...
4 |     y = tmp;
  |         ^^^ ...but data from `x` flows into `y` here

error[E0623]: lifetime mismatch
 --> learn_swap_two_references.rs:3:9
  |
1 | fn foo(mut x: &i32, mut y: &i32) {
  |               ----         ---- these two types are declared with different lifetimes...                                                                              
2 |     let tmp = x;
3 |     x = y;
  |         ^ ...but data from `y` flows into `x` here

error: aborting due to 2 previous errors

For more information about this error, try `rustc --explain E0623`.
```

这是因为交换引用的时候，两个引用的生命周期必须是相等的，因此在函数参数里指定两个引用的生命周期相同即可：

```rust
fn foo<'a>(mut x: &'a i32, mut y: &'a i32) {
```

```
2 1
```

当然，也可以用```swap```：

```rust
use std::mem::swap;
fn foo<'a>(mut x: &'a i32, mut y: &'a i32) {
    swap(&mut x, &mut y);
    println!("{} {}", x, y);
}
```


参考：<https://stackoverflow.com/questions/53835730/swapping-two-local-references-leads-to-lifetime-error>
