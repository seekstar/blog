---
title: rust学习笔记
date: 2020-08-15 10:41:03
tags:
---

[Rust编程知识拾遗：Rust 编程，读取命令行参数](https://blog.csdn.net/lcloveyou/article/details/105595040)

## 安装

```shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

或者：{% post_link Rust/'linux 非交互式安装rust' %}

安装rust之后`rustup doc`，文档就会在浏览器里打开。点击里面的The Rust Programming Language，就可以看到入门书的网页版了。

升级：`rustup update`

安装Nightly toolchain:

```shell
rustup toolchain install nightly
```

参考：

<https://rust-lang.github.io/rustup/basics.html#keeping-rust-up-to-date>

<https://rust-lang.github.io/rustup/concepts/channels.html>

<https://stackoverflow.com/questions/66681150/how-to-tell-cargo-to-use-nightly>

## cargo

### 文档

```shell
cargo doc --open
```

可以生成并在浏览器打开项目的文档。

### 新建项目

```shell
cargo new <项目名>
```

### Blocking waiting for file lock on package cache

```shell
rm -rf ~/.cargo/registry/index/*
rm ~/.cargo/.package-cache
```

<https://stackoverflow.com/questions/47565203/cargo-build-hangs-with-blocking-waiting-for-file-lock-on-the-registry-index-a#answer-53066206>

## 语法

- `_`是通配符

![在这里插入图片描述](rust学习笔记/20200814170430309.png)

这里指匹配所有的Err，不管里面是啥。

## 常见函数

### 字符串成员函数

- trim
去掉前后空格。
- parse
把字符串转成特定类型（通过要被赋值给的变量确定？）

## C语言字符串转String

原文：<https://stackoverflow.com/questions/24145823/how-do-i-convert-a-c-string-into-a-rust-string-and-back-via-ffi>

```rs
use std::ffi::CStr;
let c_buf: *const c_char = unsafe { hello() };
let c_str: &CStr = unsafe { CStr::from_ptr(c_buf) };
let str_slice: &str = c_str.to_str().unwrap();
let str_buf: String = str_slice.to_owned();  // if necessary
```
