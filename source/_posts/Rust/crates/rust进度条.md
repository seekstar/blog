---
title: rust进度条
date: 2021-07-07 16:45:40
---

用indicatif即可。
官方文档：<https://docs.rs/indicatif/0.16.2/indicatif/>

一个简单的例子：
```rust
use indicatif::ProgressBar;

fn main() {
    let bar = ProgressBar::new(1000);
    for _ in 0..1000 {
        bar.inc(1);
        std::thread::sleep(std::time::Duration::from_millis(2));
    }
    bar.finish();
}
```
