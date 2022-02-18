---
title: rust scoped thread
date: 2021-05-19 19:00:03
---

rust里，`std::thread::spawn`要求传入的闭包的生命周期必须是`'static`的，也就是说闭包中不能借用局部变量，因为rust不知道这个局部变量会不会突然就被释放了。但是一般情况下，spawn之后会调用join来确保函数返回前子线程会终止，也就是说实际上可以保证子线程在跑的时候，这个局部变量一直是有效的。

这种情况下怎么办呢？这就需要用到第三方crate：[crossbeam](https://crates.io/crates/crossbeam)。其中引入了scoped thread的概念，即通过强制join来确保子线程的生命周期局限在一个范围里，那么只要局部变量的生命周期比这个范围大，那子线程就可以借用这个局部变量了。

例子：
```rust
use crossbeam;
use std::sync::Mutex;

fn main() {
    let mut data = 233;
    crossbeam::scope(|s| {
        s.spawn(|_| {
            data += 1;
        });
    }).unwrap();
    println!("{}", data);
}
```
输出：
```
234
```
这里只可变借用（mutable borrow）了一次，所以编译可以通过。但是如果可变借用多次呢？
```rust
use crossbeam;
use std::sync::Mutex;

fn main() {
    let mut data = 233;
    crossbeam::scope(|s| {
        s.spawn(|_| {
            data += 1;
        });
        s.spawn(|_| {
            data += 1;
        });
    }).unwrap();
    println!("{}", data);
}
```
这时就会编译错误：
```
error[E0499]: cannot borrow `data` as mutable more than once at a time
  --> src/main.rs:18:17
   |
15 |         s.spawn(|_| {
   |                 --- first mutable borrow occurs here
16 |             data += 1;
   |             ---- first borrow occurs due to use of `data` in closure
17 |         });
18 |         s.spawn(|_| {
   |           ----- ^^^ second mutable borrow occurs here
   |           |
   |           first borrow later used by call
19 |             data += 1;
   |             ---- second borrow occurs due to use of `data` in closure

error: aborting due to previous error

For more information about this error, try `rustc --explain E0499`.
error: could not compile `scoped_thread`

To learn more, run the command again with --verbose.
```

要解决这个问题，就需要用到`std::sync::Mutex`了。
```rust
use crossbeam;
use std::sync::Mutex;

fn main() {
    let data = Mutex::new(233);
    crossbeam::scope(|s| {
        s.spawn(|_| {
            *data.lock().unwrap() += 1;
        });
        s.spawn(|_| {
            *data.lock().unwrap() += 1;
        });
    }).unwrap();
    println!("{}", *data.lock().unwrap());
}
```
这样就完美解决了在子线程中访问局部变量的问题了，而且不需要用`Arc<Mutex<T>>`的方式。

参考文献
<https://blog.csdn.net/shuangguo121/article/details/52328149>
<https://docs.rs/crossbeam/0.8.0/crossbeam/fn.scope.html>
<https://stackoverflow.com/questions/33116317/when-would-you-use-a-mutex-without-an-arc>
<https://zhuanlan.zhihu.com/p/357506863>
