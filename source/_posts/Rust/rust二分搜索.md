---
title: rust二分搜索
date: 2021-10-06 17:38:25
---

如果要二分搜索某个特定值，可以用```binary_search```：
<https://doc.rust-lang.org/stable/std/primitive.slice.html#method.binary_search>

如果要实现C++里的lower_bound和upper_bound类似的功能，可以用```partition_point```:
<https://doc.rust-lang.org/stable/std/primitive.slice.html#method.partition_point>

```rust
pub fn partition_point<P>(&self, pred: P) -> usize where
    P: FnMut(&T) -> bool, 
```

返回第一个使得```pred```返回false的元素的下标，与C++里的```partition_point```一样：
<http://cplusplus.com/reference/algorithm/partition_point/?kw=partition_point>

例子：

```rust
fn main() {
    let a = [1, 2, 3, 3, 4];
    // Lower bound
    println!("{}", a.partition_point(|x| *x < 3));
    // Upper bound
    println!("{}", a.partition_point(|x| *x <= 3));
}
```

```
2
4
```

相关链接：<https://github.com/rust-lang/rfcs/issues/2184>
