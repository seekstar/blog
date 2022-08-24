---
title: Rust索引String
date: 2022-08-24 15:19:46
tags:
---

Rust的String里其实是UTF-8编码的，而UTF-8是变长编码，因此会导致Rust索引String时，可能是索引第k个UTF-8字符（需要遍历字符串），也可能是索引第k个字节。因此，Rust不支持直接用下标来索引String。

如果要找到第k个UTF-8字符：

```rs
s.chars().nth(k)
```

如果要找到第k个字节：

```rs
let x: u8 = s.as_bytes()[k];
// 还可以赋值
s.as_bytes()[k] = b'x';
```

参考：

<https://stackoverflow.com/questions/24542115/how-to-index-a-string-in-rust>

<https://users.rust-lang.org/t/solved-rust-u8-literal-notation/25306>
