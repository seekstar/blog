---
title: Rust所有权和生命周期例子
date: 2022-08-31 15:22:07
tags:
---

## 返回的不可变引用的lifetime

比方说，我们在函数`f`里创建一个结构体`aa: A`来存引用`a: &i32`，但是之后我们又想把这个引用返回出去：

```rust
struct A<'a> {
    a: &'a i32,
}

impl<'a> A<'a> {
    fn a(&self) -> &i32 {
        self.a
    }
}

fn f(a: &i32) -> &i32 {
    let aa = A { a: &a };
    aa.a()
}

fn main() {
    let a = 233i32;
    println!("{}", f(&a));
}
```

这份代码是编译不过的：

```text
error[E0515]: cannot return reference to local variable `aa`
  --> life_time.rs:13:5
   |
13 |     aa.a()
   |     ^^^^^^ returns a reference to data owned by the current function

error: aborting due to previous error

For more information about this error, try `rustc --explain E0515`.
```

根据lifetime elision的原则：<https://doc.rust-lang.org/reference/lifetime-elision.html#lifetime-elision>

`A::a()`实际上被编译器认为是这样：

```rust
impl<'a> A<'a> {
    fn a(&'b self) -> &'b i32 {
        self.a
    }
}
```

也就是说编译器认为返回的引用是对整个`struct A`的引用。因此我们只需要指定返回的引用的lifetime是`'a`即可：

```diff
struct A<'a> {
    a: &'a i32,
}

impl<'a> A<'a> {
-    fn a(&self) -> &i32 {
+    fn a(&self) -> &'a i32 {
        self.a
    }
}

fn f(a: &i32) -> &i32 {
    let aa = A { a: &a };
    aa.a()
}

fn main() {
    let a = 233i32;
    println!("{}", f(&a));
}
```

## 返回临时变量里存储的可变引用

比方说，我们在函数`f`里创建一个结构体`aa: A`来存引用`a: &mut i32`，但是之后我们又想把这个可变引用返回出去：

```rust
struct A<'a> {
    a: &'a mut i32,
}

impl<'a> A<'a> {
    fn a(&'a mut self) -> &'a mut i32 {
        self.a
    }
}

fn f(a: &mut i32) -> &mut i32 {
    let mut aa = A { a };
    aa.a()
}

fn main() {
    let mut a = 233i32;
    *f(&mut a) = 2333;
    println!("{}", a);
}
```

这次我们指定了返回值的lifetime。但是仍然有编译报错：

```text
error[E0515]: cannot return reference to local variable `aa`
  --> lifetime_mut.rs:13:5
   |
13 |     aa.a()
   |     ^^^^^^ returns a reference to data owned by the current function

error: aborting due to previous error

For more information about this error, try `rustc --explain E0515`.
```

这是因为上一个例子中的不可变引用是`Copy`的，因此作为不可变引用，`self.a`是复制一份返回出去，不构成对`self`的借用。但是由于同一个对象只允许有一个有效的可变引用，因此可变引用不是`Copy`的。因此在此例中，作为可变引用，`self.a`要么是`move`，要么是对`self`的可变借用，这样才能保证可变引用的唯一性。而这里`self`也是引用，因此`self.a`就借用了`self`，也就是报错信息里说的返回值借用了临时值。

因此如果要将`self.a`返回出去，需要在`A::a()`中将`self`给consume：

```diff
struct A<'a> {
    a: &'a mut i32,
}

impl<'a> A<'a> {
-    fn a(&'a mut self) -> &'a mut i32 {
+    fn a(self) -> &'a mut i32 {
        self.a
    }
}

fn f(a: &mut i32) -> &mut i32 {
-    let mut aa = A { a };
+    let aa = A { a };
    aa.a()
}

fn main() {
    let mut a = 233i32;
    *f(&mut a) = 2333;
    println!("{}", a);
}
```

另一个例子：

```rust
struct A<'a> {
    a: &'a mut i32,
}

fn f<'a, 'b>(aa: &'b mut A<'a>) -> &'a mut i32 {
    aa.a
}

fn main() {
    let mut a = 233i32;
    let mut aa = A { a: &mut a };
    *f(&mut aa) = 2333;
    println!("{}", a);
}
```

```text
error[E0623]: lifetime mismatch
 --> move_ref_mut.rs:6:5
  |
5 | fn f<'a, 'b>(aa: &'b mut A<'a>) -> &'a mut i32 {
  |                  -------------     -----------
  |                  |
  |                  this parameter and the return type are declared with different lifetimes...
6 |     aa.a
  |     ^^^^ ...but data from `aa` is returned here

error: aborting due to previous error

For more information about this error, try `rustc --explain E0623`.
```

可以看到，由于这里`aa.a`是对`aa`的可变借用，因此需要让`aa`与返回值具有同样的生命周期：

```diff
struct A<'a> {
    a: &'a mut i32,
}

-fn f<'a, 'b>(aa: &'b mut A<'a>) -> &'a mut i32 {
+fn f<'a>(aa: &'a mut A<'a>) -> &'a mut i32 {
    aa.a
}

fn main() {
    let mut a = 233i32;
    let mut aa = A { a: &mut a };
    *f(&mut aa) = 2333;
    println!("{}", a);
}
```
