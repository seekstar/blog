---
title: rust忽略Result
date: 2021-07-15 16:42:39
---

```rust
fn main() {
    let _ = std::fs::remove_dir_all("tmp");
}
```

原文：<https://stackoverflow.com/questions/51141672/how-do-i-ignore-an-error-returned-from-a-rust-function-and-proceed-regardless>
