---
title: rust交换数组中的两个元素
date: 2021-10-20 21:52:18
---

不可以直接用```std::mem::swap```，因为这个函数需要拿两个可变引用，但是不可以同时拿两个这个数组的可变引用。

所以要么手写：

```rust
let tmp = a[i];
a[i] = a[j];
a[j] = tmp;
```

要么用```Vec::swap```：

```rust
a.swap(i, j);
```

其内部实现：

```rust
fn swap(&mut self, a: usize, b: usize) {
    unsafe {
        // Can't take two mutable loans from one vector, so instead just cast
        // them to their raw pointers to do the swap
        let pa: *mut T = &mut self[a];
        let pb: *mut T = &mut self[b];
        ptr::swap(pa, pb);
    }
}
```

原文：<https://stackoverflow.com/questions/25531963/how-can-i-swap-items-in-a-vector-slice-or-array-in-rust/25532111>
