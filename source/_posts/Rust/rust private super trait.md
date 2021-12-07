---
title: rust private super trait
date: 2021-08-03 16:13:31
---

```rust
pub(crate) mod private {

    #[doc(hidden)]
    pub trait FooPrivate<Arg> {
        fn foo(&self, arg: Arg);
    }

}

pub trait Foo<Arg>: private::FooPrivate<Arg> {

    /* other public methods */

}
```

原文：<https://jack.wrenn.fyi/blog/private-trait-methods/>
