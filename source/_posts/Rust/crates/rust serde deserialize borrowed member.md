---
title: rust serde deserialize borrowed member
date: 2021-07-27 17:04:01
---

对于borrowed成员，deserializer可以借用输入里的对应部分。serde_json序列化时会将所有部分转换成字符串，这样除非这个成员是字符串，否则deserializer就不能借用到了，会报错：
```
invalid type: sequence, expected a borrowed byte array
```

bincode序列化时会将各部分保存为二进制码，比如`&'a [u8]`成员被序列化之后仍然是一个u8字符串，因此对于大部分情况都能直接借用。

```rust
use serde::{Serialize, Deserialize};

extern crate serde_json;
extern crate bincode;

#[derive(Debug, Serialize, Deserialize)]
struct A<'a> {
    a: &'a str
}

#[derive(Debug, Serialize, Deserialize)]
struct B<'a> {
    a: &'a [u8]
}

fn main() {
    let a = "2357";
    let b = A{a};
    let res = serde_json::to_string(&b).unwrap();
    println!("serde_json(A): {:?}", res);
    let c = serde_json::from_str::<A>(&res).unwrap();
    println!("{:?}", c);

	let res = bincode::serialize(&b).unwrap();
    println!("bincode(A): {:?}", res);
    let c = bincode::deserialize::<A>(&res).unwrap();
    println!("{:?}", c);

    let a: &[u8] = &[2, 3, 5, 7, 11, 13];
    let b = B{a};
    let res = serde_json::to_string(&b).unwrap();
    println!("serde_json(B): {:?}", res);
    let res = bincode::serialize(&b).unwrap();
    println!("bincode(B): {:?}", res);
    //let c = serde_json::from_str::<B>(&res).unwrap();
    let c = bincode::deserialize::<B>(&res).unwrap();
    println!("{:?}", c);
}
```
```
serde_json(A): "{\"a\":\"2357\"}"
A { a: "2357" }
bincode(A): [4, 0, 0, 0, 0, 0, 0, 0, 50, 51, 53, 55]
A { a: "2357" }
serde_json(B): "{\"a\":[2,3,5,7,11,13]}"
bincode(B): [6, 0, 0, 0, 0, 0, 0, 0, 2, 3, 5, 7, 11, 13]
B { a: [2, 3, 5, 7, 11, 13] }
```
可以看到反序列化`A`时需要借用一个字符串，而这`serde_json`序列化的结果中字符串刚好原样保留了，所以可以直接借用。bincode序列化A时，字符串也被原样保留了，所以也能直接借用。

反序列化`B`时需要借用一个u8数组，`serde_json`序列化会将它变成一个字符串，`bincode`序列化的结果中u8数组才会原样保留。所以用bincode才能顺利进行反序列化。

参考文献：
<https://serde.rs/lifetimes.html>
