---
title: rust学习笔记
date: 2020-08-15 10:41:03
tags:
---

安装rust之后
```shell
rustup doc
```
文档就会在浏览器里打开。点击里面的The Rust Programming Language，就可以看到入门书的网页版了。

# cargo
## 文档
```shell
cargo doc --open
```
可以生成并在浏览器打开项目的文档。

## 新建项目
```shell
cargo new <项目名>
```

# 语法
- _是通配符
![在这里插入图片描述](rust学习笔记/20200814170430309.png#pic_center)
这里指匹配所有的Err，不管里面是啥。
- 
# 常见函数
## 字符串成员函数
- trim
去掉前后空格。
- parse
把字符串转成特定类型（通过要被赋值给的变量确定？）
