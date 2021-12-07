---
title: rust多行字符串字面量
date: 2021-07-06 15:56:07
---

```rust
let string = "line one
    line two";
```
相当于```line one\n    line two```，注意第二行的前导空格还在。

```rust
let string = "one line \
    written over \
    several";
```
相当于```one line written over several```，注意前导空格被忽略了。

```rust
let string = "multiple\n\
              lines\n\
              with\n\
              indentation";
```
相当于```multiple\nlines\nwith\nindentation```

原文：<https://stackoverflow.com/questions/29483365/what-is-the-syntax-for-a-multiline-string-literal>
