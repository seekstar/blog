---
title: Rust vector reduce size
date: 2022-08-26 22:11:13
tags:
---

`resize` requires a default value:

```rs
fn resize(&mut self, new_len: usize, value: T)
```

While `truncate` does not:

```rs
fn truncate(&mut self, len: usize)
```

If len is greater than the vector's current length, `truncate` has no effect.

Document: <https://static.rust-lang.org/doc/master/std/vec/struct.Vec.html>
