---
title: rust学习笔记
date: 2020-08-15 10:41:03
tags:
---

## 安装

```shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

或者：{% post_link Rust/'linux 非交互式安装rust' %}

安装rust之后`rustup doc`，文档就会在浏览器里打开。点击里面的The Rust Programming Language，就可以看到入门书的网页版了。

升级：`rustup update`

安装Nightly toolchain:

```shell
rustup toolchain install nightly
```

参考：

<https://rust-lang.github.io/rustup/basics.html#keeping-rust-up-to-date>

<https://rust-lang.github.io/rustup/concepts/channels.html>

<https://stackoverflow.com/questions/66681150/how-to-tell-cargo-to-use-nightly>

## cargo

### 文档

```shell
cargo doc --open
```

可以生成并在浏览器打开项目的文档。

### 新建项目

```shell
cargo new <项目名>
```

### Blocking waiting for file lock on package cache

```shell
rm -rf ~/.cargo/registry/index/*
rm ~/.cargo/.package-cache
```

<https://stackoverflow.com/questions/47565203/cargo-build-hangs-with-blocking-waiting-for-file-lock-on-the-registry-index-a#answer-53066206>

## 标准库

### `Vec<u8>` -> `String`

<https://stackoverflow.com/questions/19076719/how-do-i-convert-a-vector-of-bytes-u8-to-a-string>

<https://doc.rust-lang.org/stable/std/string/struct.String.html#method.from_utf8>

### 字符串成员函数

- trim
去掉前后空格。
- parse
把字符串转成特定类型（通过要被赋值给的变量确定？）

### 排序

复杂度稳定的排序用`sort_by`：<https://doc.rust-lang.org/std/primitive.slice.html#method.sort_by>

复杂度不稳定但是常数小的排序用`sort_unstable_by`：<https://doc.rust-lang.org/std/primitive.slice.html#method.sort_unstable_by>

### 多线程

原子量：<https://doc.rust-lang.org/std/sync/atomic/index.html>

### Entry API

以BTreeMap的Entry API为例。基础用法见标准库文档：<https://doc.rust-lang.org/stable/std/collections/struct.BTreeMap.html#method.entry>

这里介绍如何用它实现modify and optionally remove：

```rs
use std::collections::btree_map::{self, BTreeMap};

fn pop(m: &mut BTreeMap<u32, Vec<u32>>, key: u32) -> Option<u32> {
    match m.entry(key) {
        btree_map::Entry::Occupied(mut entry) => {
            let values = entry.get_mut();
            let ret = values.pop();
            if values.is_empty() {
                entry.remove();
            }
            ret
        }
        btree_map::Entry::Vacant(_) => {
            None
        }
    }    
}
fn main() {
    let mut m: BTreeMap<u32, Vec<u32>> = BTreeMap::new();
    m.insert(1, vec![2, 3]);
    assert_eq!(pop(&mut m, 1), Some(3));
    assert_eq!(pop(&mut m, 1), Some(2));
    assert!(m.is_empty());
}
```

参考：

<https://doc.rust-lang.org/stable/std/collections/btree_map/enum.Entry.html>

<https://doc.rust-lang.org/stable/std/collections/btree_map/struct.VacantEntry.html>

## Crates

### serde

{% post_link Rust/'rust serde deserialize borrowed member' %}

{% post_link Rust/'rust存取一个含有borrowed域的结构体' %}

<https://serde.rs/attr-skip-serializing.html>

<https://github.com/serde-rs/json#operating-on-untyped-json-values>

### 其他

enum_iterator: <https://docs.rs/enum-iterator/latest/enum_iterator/>

可以获取enum的可能取值个数。

num-derive: <https://docs.rs/num-derive/latest/num_derive/>

可以把enum转成基本类型。

## 语法

[Rust for循环](https://www.yiibai.com/rust/rust-for-loop.html)

- `_`是通配符

![在这里插入图片描述](rust学习笔记/20200814170430309.png)

这里指匹配所有的Err，不管里面是啥。

<https://users.rust-lang.org/t/calling-function-in-struct-field-requires-extra-parenthesis/14214/2>

### 约束不同类型的associated type相等

这是一个未实现的特性：<https://github.com/rust-lang/rust/issues/20041>

但是可以绕过去：<https://stackoverflow.com/questions/66359551/alternative-to-equality-constraints-for-associated-types>

## I/O

- {% post_link Rust/'Rust文件操作' %}

- {% post_link Rust/'rust格式化打印到文件' %}

- {% post_link Rust/'算法竞赛中rust的一种比较健壮的读入' %}

- {% post_link Rust/'rust识别EOF' %}

- {% post_link Rust/'rust-BufReader逐字符读取' %}

- {% post_link Rust/'rust单行读取多个整数' %}

- {% post_link Rust/'rust从一行中读取数组' %}

- {% post_link Rust/'rust用BufReader加速stdin读取' %}

- {% post_link Rust/'rust格式控制' %}

- {% post_link Rust/'rust print固定宽度左边补零' %}

### 读取命令行参数

```rs
use std::io;
use std::env;
use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {
    let mut args = env::args();
    let arg0 = args.next().unwrap();
    // args.len(): Returns the exact remaining length of the iterator.
    if args.len() != 1 {
        eprintln!("{} dump-file", arg0);
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            "Invalid arguments",
        )));
    }
    let file_path = args.next().unwrap();
    println!("{}", file_path);
    Ok(())
}
```

参考：[Rust编程知识拾遗：Rust 编程，读取命令行参数](https://blog.csdn.net/lcloveyou/article/details/105595040)

### 从文件中逐行读取

```rs
let file = File::open("path")?;
let reader = BufReader::new(file);
```

参考：[在 Rust 中读取文件的 4 种方法](https://blog.csdn.net/qq_29607687/article/details/125438652)

## C语言字符串转String

原文：<https://stackoverflow.com/questions/24145823/how-do-i-convert-a-c-string-into-a-rust-string-and-back-via-ffi>

```rs
use std::ffi::CStr;
let c_buf: *const c_char = unsafe { hello() };
let c_str: &CStr = unsafe { CStr::from_ptr(c_buf) };
let str_slice: &str = c_str.to_str().unwrap();
let str_buf: String = str_slice.to_owned();  // if necessary
```

## trait

Rust的trait相当于定义了这个类型有哪些接口。定义了trait之后，可以对已知类型实现这个trait:

```rs
trait A {
    fn a() -> i32;
}
impl A for f32 {
    fn a() -> i32 {
        return 2333;
    }
}
fn main() {
    // 2333
    println!("{}", f32::a());
}
```

相关：

<https://stackoverflow.com/questions/44445730/how-to-call-a-method-when-a-trait-and-struct-use-the-same-method-name>

<https://users.rust-lang.org/t/box-with-a-trait-object-requires-static-lifetime/35261>

## 获得`Vec`里多个元素的mutable reference

比如要获得`a[1]`和`a[3]`的可变引用，可以用iterator:

```rs
fn main() {
    let mut a = vec![0, 1, 2, 3, 4, 5];
    let mut iter = a.iter_mut();
    let a1 = iter.nth(1).unwrap();
    let a3 = iter.nth(3 - 1 - 1).unwrap();
    *a1 = -1;
    *a3 = -1;
    println!("{:?}", a);
}
```

也可以用nightly特性`get_many_mut`:

```rs
#![feature(get_many_mut)]
fn main() {
    let mut a = vec![0, 1, 2, 3, 4, 5];
    let [a1, a3] = a.get_many_mut([1, 3]).unwrap();
    *a1 = -1;
    *a3 = -1;
    println!("{:?}", a);
}
```

## struct成员变量默认值

<https://stackoverflow.com/questions/19650265/is-there-a-faster-shorter-way-to-initialize-variables-in-a-rust-struct>

## 生成随机数

用`rand` crate。文档：<https://docs.rs/rand/latest/rand/>。

基础用法：<https://docs.rs/rand/latest/rand/#quick-start>

自带的随机数生成器：<https://docs.rs/rand/latest/rand/rngs/index.html>

如果需要指定随机种子的话，一般`rand::rngs::StdRng`即可满足需求，文档：<https://docs.rs/rand/latest/rand/rngs/struct.StdRng.html>

一些自带的分布：<https://docs.rs/rand/latest/rand/distributions/index.html>

比较常见的均匀分布：<https://docs.rs/rand/latest/rand/distributions/struct.Uniform.html>

## lower_bound / upper_bound

<https://stackoverflow.com/questions/48575866/how-to-get-the-lower-bound-and-upper-bound-of-an-element-in-a-btreeset>

## char -> u8

<https://users.rust-lang.org/t/how-to-convert-char-to-u8/50195>

## 让main函数兼容多种Error

```rs
use std::error::Error;
fn main() -> Result<(), Box<dyn Error>> {
```

## Module

<https://doc.rust-lang.org/book/ch07-05-separating-modules-into-different-files.html>

## 条件编译

官方文档：<https://doc.rust-lang.org/reference/conditional-compilation.html>

<https://stackoverflow.com/questions/29857002/how-to-define-test-only-dependencies>

仅在测试时derive: `#[cfg_attr(test, derive(Deserialize))]`。来源：<https://www.reddit.com/r/rust/comments/nwywqx/conditionally_derive_for_integration_tests/>

仅在测试时`impl`:

```rs
#[cfg(test)]
impl Default for Status {
```

## 已知问题

### Non-lexical lifetimes (NLL)

来源：<https://blog.rust-lang.org/2022/08/05/nll-by-default.html>

```rs
fn last_or_push<'a>(vec: &'a mut Vec<String>) -> &'a String {
    if let Some(s) = vec.last() { // borrows vec
        // returning s here forces vec to be borrowed
        // for the rest of the function, even though it
        // shouldn't have to be
        return s; 
    }
    
    // Because vec is borrowed, this call to vec.push gives
    // an error!
    vec.push("".to_string()); // ERROR
    vec.last().unwrap()
}
```

```text
error[E0502]: cannot borrow `*vec` as mutable because it is also borrowed as immutable
  --> a.rs:11:5
   |
1  | fn last_or_push<'a>(vec: &'a mut Vec<String>) -> &'a String {
   |                 -- lifetime `'a` defined here
2  |     if let Some(s) = vec.last() { // borrows vec
   |                      ---------- immutable borrow occurs here
...
6  |         return s; 
   |                - returning this value requires that `*vec` is borrowed for `'a`
...
11 |     vec.push("".to_string()); // ERROR
   |     ^^^^^^^^^^^^^^^^^^^^^^^^ mutable borrow occurs here
```

这是因为`s` borrow了`vec`之后，`s`是conditional return的，但是编译器仍然将对`vec`的borrow拓展到所有条件分支了，就导致另一个没有borrow `vec`的分支也被认为borrow了`vec`，就编译报错了。

据说下一代borrow checker polonius可以解决这个问题。现在只能通过推迟对`vec`的borrow绕过这个问题：

```rs
fn last_or_push<'a>(vec: &'a mut Vec<String>) -> &'a String {
    if !vec.is_empty() {
        let s = vec.last().unwrap(); // borrows vec
        return s; // extends the borrow 
    }
    
    // In this branch, the borrow has never happened, so even
    // though it is extended, it doesn't cover this call;
    // the code compiles.
    //
    // Note the subtle difference with the previous example:
    // in that code, the borrow *always* happened, but it was
    // only *conditionally* returned (but the compiler lost track
    // of the fact that it was a conditional return).
    //
    // In this example, the *borrow itself* is conditional.
    vec.push("".to_string());
    vec.last().unwrap()
}

fn main() { }
```
