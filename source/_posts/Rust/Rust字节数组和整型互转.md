---
title: Rust字节数组和整型互转
date: 2022-10-18 22:23:25
tags:
---

## 整型转字节数组

小端序：`i16::to_le_bytes`

大端序：`i16::to_be_bytes`

## 字节数组转整型

小端序：`i16::from_le_bytes`

大端序：`i16::from_be_bytes`

## 例子

```rs
fn main() {
    let bytes: [u8; 2] = [1, 2];
    assert_eq!(i16::from_le_bytes(bytes), (2 << 8) + 1);
    assert_eq!(i16::from_be_bytes(bytes), (1 << 8) + 2);
    let x: i16 = (2 << 8) + 1;
    assert_eq!([1, 2], x.to_le_bytes());
    assert_eq!([2, 1], x.to_be_bytes());
}
```
