---
title: rust const generic
date: 2021-07-14 12:44:56
---

```rust
struct ModVal<const P: usize> {
    v: usize
}
impl<const P: usize> ModVal<P> {
    // std::assert!(P + P <= usize::Max());
    fn new(v: usize) -> Self {
        Self { v }
    }
}
impl<const P: usize> std::ops::AddAssign<usize> for ModVal<P> {
    fn add_assign(&mut self, x: usize) {
        self.v += x; // Assumed not overflow here
        self.v %= P;
    }
}

fn main() {
    let mut v = ModVal::<5>::new(2);
    v += 4;
    assert_eq!(v.v, 1);
}
```

目前的1.53.0版本的rustc还不支持`struct ModVal<T, const P: T>`这种，不然会报错：
```
the type must not depend on the parameter `T`
```
不过可以用宏来实现类似的功能：

```rust
macro_rules! define_mod_val {
    ($name:ident, $t:ty) => {
        struct $name<const P: $t> {
            v: $t
        }
        impl<const P: $t> $name<P> {
            fn new(v: $t) -> Self {
                Self { v }
            }
        }
        impl<const P: $t> std::ops::AddAssign<$t> for $name<P> {
            fn add_assign(&mut self, x: $t) {
                self.v += x; // Assumed not overflow here
                self.v %= P;
            }
        }
    }
}

define_mod_val!(ModValUsize, usize);
define_mod_val!(ModValI32, i32);

fn main() {
    let mut v = ModValUsize::<5>::new(2);
    v += 4;
    assert_eq!(v.v, 1);

    let mut v = ModValI32::<5>::new(2);
    v += 4;
    assert_eq!(v.v, 1);
}
```
