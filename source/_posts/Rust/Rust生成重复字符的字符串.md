---
title: Rust生成重复字符的字符串
date: 2022-08-24 14:58:10
tags:
---

```rs
std::iter::repeat('x').take(len).collect::<String>()
```

来源：<https://users.rust-lang.org/t/fill-string-with-repeated-character/1121>
