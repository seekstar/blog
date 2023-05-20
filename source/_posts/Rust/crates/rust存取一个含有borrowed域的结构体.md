---
title: rust存取一个含有borrowed域的结构体
date: 2021-07-28 10:31:32
---

直接存取不可以：

```rust
use std::io;

use serde::{Serialize, Deserialize};

extern crate bincode;

#[derive(Debug, Serialize, Deserialize)]
struct A<'a> {
    a: &'a [u8]
}

fn main() {
    let a: &[u8] = &[2, 3, 5, 7, 11, 13];
    let b = A{a};
    let mut v = Vec::new();
    bincode::serialize_into(&mut v, &b).unwrap();

    let mut reader = io::Cursor::new(&v);
    let c = bincode::deserialize_from::<_, A>(&mut reader).unwrap();
    println!("{:?}", c);
}
```

会报错：

```text
error: implementation of `Deserialize` is not general enough
  --> src/main.rs:19:13
   |
19 |     let c = bincode::deserialize_from::<_, A>(&mut reader).unwrap();
   |             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ implementation of `Deserialize` is not general enough
   |
   = note: `A<'_>` must implement `Deserialize<'0>`, for any lifetime `'0`...
   = note: ...but `A<'_>` actually implements `Deserialize<'1>`, for some specific lifetime `'1`

error: could not compile `serde-borrowed` due to previous error
```

这是因为BufWriter里的缓存的所有权不是调用者的，可能会被释放，这样构造含有borrowed域的结构体时就不能安全地借用读出来的数据了。

可以用`std::borrow::Cow`实现在serialize的时候borrow，但是在deserialize的时候create，从而解决这个问题:

```rs
use std::{io, borrow::Cow};

use serde::{Serialize, Deserialize};

extern crate bincode;

#[derive(Debug, Serialize, Deserialize)]
struct A<'a> {
    a: Cow<'a, [u8]>,
}

fn main() {
    let a: &[u8] = &[2, 3, 5, 7, 11, 13];
    let b = A{a: Cow::Borrowed(a)};
    let mut v = Vec::new();
    bincode::serialize_into(&mut v, &b).unwrap();

    let mut reader = io::Cursor::new(&v);
    let c = bincode::deserialize_from::<_, A>(&mut reader).unwrap();
    if let Cow::Borrowed(_) = c.a {
        panic!();
    }
    println!("{:?}", c);
}
```

此外，bincode有`forward_read_*`系列函数，好像也可以通过转移所有权解决这个问题：
<https://docs.rs/bincode/1.3.1/bincode/de/read/trait.BincodeRead.html>
但是我不会。

## 参考文献

<https://stackoverflow.com/questions/60801133/how-do-i-use-serde-to-deserialize-structs-with-references-from-a-reader>

<https://stackoverflow.com/questions/52733047/how-to-borrow-a-field-for-serialization-but-create-it-during-deserialization>

[How to deserialize maybe-borrowed maybe-copied data?](https://github.com/serde-rs/serde/issues/914)
