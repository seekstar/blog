---
title: Rust文件操作
date: 2022-10-14 21:27:13
tags:
---

## 文件管理

### `mkdir`

<https://doc.rust-lang.org/std/fs/fn.create_dir.html>

### `mkdir -p`

<https://doc.rust-lang.org/std/fs/fn.create_dir_all.html>

### `mv`

<https://doc.rust-lang.org/std/fs/fn.rename.html>

## 临时文件/目录

<https://crates.io/crates/tempfile>

临时目录：<https://docs.rs/tempfile/latest/tempfile/fn.tempdir.html>

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

## 从文件中逐行读取

```rs
let file = File::open("path")?;
let reader = BufReader::new(file);
for line in reader.lines() {
    println!("{}", line?);
}
```

值得注意的是，`io::stdin()`也可以这样：

```rs
for line in io::stdin().lines() {
    println!("{}", line?);
}
```

参考：[在 Rust 中读取文件的 4 种方法](https://blog.csdn.net/qq_29607687/article/details/125438652)

## 在文件中从后往前逐行读取

用crate `rev_lines`: <https://github.com/mjc-gh/rev_lines>

或者crate `rev_buf_reader`: <https://github.com/andre-vm/rev_buf_reader>

相关讨论：<https://users.rust-lang.org/t/idiomatic-way-of-reading-a-text-file-line-by-line-in-reverse/8547>

但是这两个crate好像都没有prefetch，导致每次读取都要卡一下。

## 其他

{% post_link Rust/IO/'rust格式化打印到文件' %}
