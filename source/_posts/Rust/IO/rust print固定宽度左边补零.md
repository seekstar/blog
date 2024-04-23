---
title: rust print固定宽度左边补零
date: 2020-08-25 19:34:43
tags:
---

参考：<https://doc.rust-lang.org/std/fmt/>

## 任意类型

```rust
fn main() {
    println!("{:0>3}", 2333);
    println!("{:0>3}", 233);
    println!("{:0>3}", 23);
    println!("{:0>3}", 2);
    println!("{:0>3}", 0);
    println!("{:0>3}", -2);

    println!("{:0>3}", "test");                                                 
    println!("{:0>3}", "tes");                                                  
    println!("{:0>3}", "te");
    println!("{:0>3}", "t");
}
```

其中`>`表示向右对齐，`0`是在左边补的字符。

```text
2333
233
023
002
000
0-2
test
tes
0te
00t
```

## 整型

```rust
fn main() {                                                                     
    println!("{:03}", 2333);                                                    
    println!("{:03}", 233);                                                     
    println!("{:03}", 23);                                                      
    println!("{:03}", 2);                                                       
    println!("{:03}", -2);                                                      
}
```

```text
2333
233
023
002
-02
```

## 变量指定的宽度

```rust
fn main() {                                                                     
    for i in 1..5 {                                                             
        println!("{:01$}", 23, i);                                              
    }                                                                           
}
```

```text
23
23
023
0023
```
