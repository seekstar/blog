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
```

如果要修改第k个字节，则需要`unsafe`，因此这一步可能会导致出现无效的UTF-8字符：

```rust
unsafe { s.as_bytes_mut()[len - 1] = b'-'; }
```

参考：

<https://stackoverflow.com/questions/24542115/how-to-index-a-string-in-rust>

<https://users.rust-lang.org/t/solved-rust-u8-literal-notation/25306>

<https://doc.rust-lang.org/std/primitive.str.html#method.as_bytes_mut>
