---
title: rust 定时执行
date: 2021-08-16 16:20:40
---

```toml
tokio = { "version" = "1.10", features = ["full"] }
```

```rust
use tokio::time;

async fn print() {
    let mut interval = time::interval(time::Duration::from_secs(1));
    loop {
        interval.tick().await;
        println!("2333");
    }
}

#[tokio::main]
async fn main() {
    tokio::spawn(print());
    std::thread::sleep(std::time::Duration::from_secs(3));
}
```

```
2333
2333
2333
```
