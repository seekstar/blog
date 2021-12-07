---
title: rust打印变量类型
date: 2021-09-29 20:30:45
---

可以试试```std::any::type_name```。注意，这个是unstable的。

```rs
use std::collections::HashSet;

fn print_type_of<T>(_: &T) {
    println!("{}", std::any::type_name::<T>())
}

fn main() {
    let mut s = HashSet::new();
    let ve = vec![1, 2, 1, 3, 2, 4];
    print_type_of(&s);
    for v in &ve {
        println!("{}", s.insert(v));
    }
}
```

```
std::collections::hash::set::HashSet<&i32>
true
true
false
true
false
true
```

参考文献：
[如何在Rust中打印一个变量的类型？](https://www.zhihu.com/question/424336709/answer/1509450780)
<https://stackoverflow.com/questions/21747136/how-do-i-print-the-type-of-a-variable-in-rust/43508373#43508373>
<https://doc.rust-lang.org/stable/std/any/fn.type_name.html>
