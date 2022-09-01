---
title: cargo build带优化
date: 2022-09-01 19:16:16
tags:
---

`Cargo.toml`:

```toml
[profile.dev]
opt-level = 3
```

然后`cargo build`:

```text
    Finished dev [optimized + debuginfo] target(s) in 6.35s
```
