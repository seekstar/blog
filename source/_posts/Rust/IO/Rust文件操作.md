---
title: Rust文件操作
date: 2022-10-14 21:27:13
tags:
---

## Path

官方文档：<https://doc.rust-lang.org/std/path/struct.Path.html>

常用：

```rs
assert_eq!(Path::new("/etc").join("passwd"), PathBuf::from("/etc/passwd"));
```

## 错误处理

官方文档：<https://doc.rust-lang.org/std/io/struct.Error.html>

常用：

```rs
// On Linux
let error = io::Error::from_raw_os_error(22);
assert_eq!(error.kind(), io::ErrorKind::InvalidInput);
```

## 其他

{% post_link Rust/IO/'rust格式化打印到文件' %}
