---
title: rust存取一个含有borrowed域的结构体
date: 2021-07-28 10:31:32
---

直接存取不可以：
```rust
use std::fs::File;
use std::io::{BufWriter, BufReader};

use serde::{Serialize, Deserialize};

extern crate bincode;

#[derive(Debug, Serialize, Deserialize)]
struct A<'a> {
    a: &'a [u8]
}

fn main() {
    let a: &[u8] = &[2, 3, 5, 7, 11, 13];
    let b = A{a};
    let writer = BufWriter::new(File::create("test").unwrap());
    bincode::serialize_into(&mut writer, &b).unwrap();
    drop(writer);

    let mut reader = BufReader::new(File::open("test").unwrap());
    let c = bincode::deserialize_from::<_, A>(&mut reader).unwrap();
    println!("{:?}", c);
}
```
会报错：
```
error: implementation of `Deserialize` is not general enough
  --> src/main.rs:21:13
   |
21 |     let c = bincode::deserialize_from::<_, A>(&mut reader).unwrap();
   |             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ implementation of `Deserialize` is not general enough
   |
   = note: `A<'_>` must implement `Deserialize<'0>`, for any lifetime `'0`...
   = note: ...but `A<'_>` actually implements `Deserialize<'1>`, for some specific lifetime `'1`

error: aborting due to previous error
```

这是因为BufWriter里的缓存的所有权不是调用者的，可能会被释放，这样构造含有borrowed域的结构体时就不能安全地借用读出来的数据了。解决方法就是把这个结构体对应的文件数据读出来存到一个变量里，然后用```bincode::deserialize```来把结构体构造出来。一种简单的方法是构造一个wrapper:

```rust
#[derive(Debug, Serialize, Deserialize)]
struct Wrapper {
    data: Box<[u8]>,
}
```

然后先把结构体序列化到这个wrapper里，再将wrapper序列化到文件里。读的时候先把这个wrapper反序列化出来，这样这个wrapper就拿到了结构体的文件数据的所有权了，再用```bincode::deserialize```来把结构体构造出来。完整代码如下。

```rust
use std::fs::File;
use std::io::{Write, BufWriter, BufReader};

use serde::{Serialize, Deserialize};

extern crate bincode;

#[derive(Debug, Serialize, Deserialize)]
struct Wrapper {
    data: Box<[u8]>,
}

#[derive(Debug, Serialize, Deserialize)]
struct A<'a> {
    a: &'a [u8]
}

pub fn serialize_into_file_wrapped<W, T: ?Sized>(
    writer: W, value: &T
) -> std::result::Result<(), Box<bincode::ErrorKind>>
where
    W: Write,
    T: Serialize,
{
    let data = Box::from(bincode::serialize(value)?);
    bincode::serialize_into(writer, &Wrapper{data})
}

fn main() {
    let a: &[u8] = &[2, 3, 5, 7, 11, 13];
    let b = A{a};
    let mut writer = BufWriter::new(File::create("test").unwrap());
    serialize_into_file_wrapped(&mut writer, &b).unwrap();
    drop(writer);

    let mut reader = BufReader::new(File::open("test").unwrap());
    let wrapper: Wrapper = bincode::deserialize_from(&mut reader).unwrap();
    let c: A = bincode::deserialize(&wrapper.data).unwrap();
    println!("{:?}", c);
}
```

```
A { a: [2, 3, 5, 7, 11, 13] }
```

bincode有```forward_read_*```系列函数，好像也可以通过转移所有权解决这个问题：
<https://docs.rs/bincode/1.3.1/bincode/de/read/trait.BincodeRead.html>
但是我不会。


参考文献：
<https://stackoverflow.com/questions/60801133/how-do-i-use-serde-to-deserialize-structs-with-references-from-a-reader>
