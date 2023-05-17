---
title: rust识别EOF
date: 2020-08-17 16:45:54
tags:
---

参考：<https://stackoverflow.com/questions/41210691/how-to-check-for-eof-in-read-line-in-rust-1-12>
如果read_line返回的是Ok(0)那么就是EOF了。
跟空行的区别在于空行实际上还有一个换行符，所以是Ok(1)。
```rust
        let mut input = String::new();
        loop {
            if 0 == io::stdin().read_line(&mut input).unwrap() {
                return;	// EOF
            }
            if !input.trim().is_empty() {
                break;
            }
        }
```
