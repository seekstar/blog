---
title: Rust文件操作
date: 2022-10-14 21:27:13
tags:
---

## 获取文件长度

```rs
let file = File::open(path)?;
let len = file.metadata()?.len();
```

参考：

<https://doc.rust-lang.org/stable/std/fs/struct.File.html#method.metadata>

<https://doc.rust-lang.org/stable/std/fs/struct.Metadata.html>

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

## 从文件中读取整型

如果只用标准库里的safe rust的话，只能先读进一个buffer里，然后再转成integer：<https://stackoverflow.com/questions/70466567/read-binary-file-in-units-of-f64-in-rust>。定义buffer的时候一般得初始化为0，而且后面将buffer转换成integer也需要一次复制（虽然可能会被编译器优化掉）。例子：

```rs
let mut reader = io::Cursor::new([1u8, 2u8, 3u8, 4u8]);
let mut buf = [0u8; 4]; 
reader.read_exact(&mut buf).unwrap();
let v = u32::from_le_bytes(buf);
assert_eq!(v, 0x04030201);
```

相关：

<https://github.com/rust-lang/rfcs/blob/master/text/2930-read-buf.md>

<https://docs.rs/binread/latest/binread/>

## 其他

{% post_link Rust/IO/'rust格式化打印到文件' %}
