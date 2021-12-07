---
title: rust泛型初始化成0
date: 2020-09-04 00:02:25
tags:
---

std::num::Int被deprecated了。所以只能用别人的crate或者自己实现Zero了。

github上有一个不错的：
<https://github.com/rust-num/num-traits>
有关Zero的部分：
```rust
pub trait Zero {
    fn zero() -> Self;
    fn is_zero(&self) -> bool;
}
macro_rules! zero_impl {
    ($t:ty, $v:expr) => {
        impl Zero for $t {
            #[inline]
            fn zero() -> $t {
                $v
            }
            #[inline]
            fn is_zero(&self) -> bool {
                *self == $v
            }
        }
    };
}
zero_impl!(usize, 0);
zero_impl!(u8, 0);
zero_impl!(u16, 0);
zero_impl!(u32, 0);
zero_impl!(u64, 0);
#[cfg(has_i128)]
zero_impl!(u128, 0);

zero_impl!(isize, 0);
zero_impl!(i8, 0);
zero_impl!(i16, 0);
zero_impl!(i32, 0);
zero_impl!(i64, 0);
#[cfg(has_i128)]
zero_impl!(i128, 0);

zero_impl!(f32, 0.0);
zero_impl!(f64, 0.0);
```
把这段复制一下就可以用```Zero```trait了。
示例：
```rust
pub trait Zero {
    fn zero() -> Self;
    fn is_zero(&self) -> bool;
}
macro_rules! zero_impl {
    ($t:ty, $v:expr) => {
        impl Zero for $t {
            #[inline]
            fn zero() -> $t {
                $v
            }
            #[inline]
            fn is_zero(&self) -> bool {
                *self == $v
            }
        }
    };
}
zero_impl!(usize, 0);
zero_impl!(u8, 0);
zero_impl!(u16, 0);
zero_impl!(u32, 0);
zero_impl!(u64, 0);
#[cfg(has_i128)]
zero_impl!(u128, 0);

zero_impl!(isize, 0);
zero_impl!(i8, 0);
zero_impl!(i16, 0);
zero_impl!(i32, 0);
zero_impl!(i64, 0);
#[cfg(has_i128)]
zero_impl!(i128, 0);

zero_impl!(f32, 0.0);
zero_impl!(f64, 0.0);

fn print<T: Zero + std::fmt::Display + std::clone::Clone>(x: T) {
    println!("{}", x);
    let test = vec![T::zero(); 10];
    for x in test.iter() {
        println!("{}", x);
    }
}

fn main() {
    print(233);
    print(233.0);
}
```
输出：
```
233
0
0
0
0
0
0
0
0
0
0
233
0
0
0
0
0
0
0
0
0
0
```
