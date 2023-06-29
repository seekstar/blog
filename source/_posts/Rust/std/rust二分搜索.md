---
title: rust二分搜索
date: 2021-10-06 17:38:25
---

如果要二分搜索某个特定值，可以用`binary_search`：
<https://doc.rust-lang.org/stable/std/primitive.slice.html#method.binary_search>

如果要实现C++里的lower_bound和upper_bound类似的功能，可以用`partition_point`:
<https://doc.rust-lang.org/stable/std/primitive.slice.html#method.partition_point>

```rust
pub fn partition_point<P>(&self, pred: P) -> usize where
    P: FnMut(&T) -> bool, 
```

返回第一个使得`pred`返回false的元素的下标，与C++里的`partition_point`一样：
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

```text
2
4
```

相关：[Add lower_bound, upper_bound and equal_range for slices where T: Ord to complement binary_search](https://github.com/rust-lang/rfcs/issues/2184)

但是要注意的是，如果要搜索某个符合条件的值，那么不要用`collect`做一个`Vec`再用`partition_point`，因为rust（目前）并不会将这个构建`Vec`的过程优化掉，时间复杂度和空间复杂度都是`O(n)`。例子：

```rs
fn main() {
    println!("{}", (0usize..2usize.pow(29)).collect::<Vec<usize>>().partition_point(|v| v < &233usize));
}
```

内存使用量会达到4GB。

自己写一个二分搜索就不存在这个问题了：

```rs
fn partition_point_addable<T, F>(mut start: T, mut end: T, pred: F) -> T
where
    T: Copy
        + Add<T, Output = T>
        + Sub<T, Output = T>
        + PartialEq
        + One
        + Shr<i8, Output = T>,
    F: Fn(&T) -> bool,
{
    while start != end {
        let mid = start + ((end - start) >> 1);
        if pred(&mid) {
            start = mid + T::one();
        } else {
            end = mid;
        }
    }
    start
}
```
