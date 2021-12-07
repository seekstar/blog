---
title: rust scoped thread pool
date: 2021-08-09 16:53:11
---

用rayon即可。

```rust
mod a {
    fn fun(a: &mut i32) -> i32 {
        *a += 1;
        return *a + 233;
    }
    pub fn main() {
        let mut a = 233;
        let pool = rayon::ThreadPoolBuilder::new().num_threads(8).build().unwrap();
        let ret = pool.install(|| fun(&mut a));
        println!("{} {}", ret, a);
    }
}
mod b {
    use std::sync::atomic::{AtomicU64, Ordering};
    fn fun(a: &AtomicU64) {
        a.fetch_add(1, Ordering::Relaxed);
    }
    pub fn main() {
        let a = AtomicU64::new(0);
        let pool = rayon::ThreadPoolBuilder::new().num_threads(8).build().unwrap();
        pool.in_place_scope(|s| {
            for _ in 0..233 {
                s.spawn(|_| fun(&a));
            }
            print!("{} ", a.load(Ordering::Relaxed));
        });
        println!("{}", a.load(Ordering::Relaxed));
    }
}
mod c {
    use std::sync::Mutex;
    fn fun(a: &Mutex<i32>) {
        *a.lock().unwrap() += 1;
    }
    pub fn main() {
        let a = Mutex::new(0);
        let pool = rayon::ThreadPoolBuilder::new().num_threads(8).build().unwrap();
        pool.in_place_scope(|s| {
            for _ in 0..233 {
                s.spawn(|_| fun(&a));
            }
            print!("{} ", *a.lock().unwrap());
        });
        println!("{}", *a.lock().unwrap());
    }
}

fn main() {
    a::main();
    b::main();
    c::main();
}
```

```
467 234
231 233
217 233
```

完整文档：<https://docs.rs/rayon/1.5.1/rayon/struct.ThreadPool.html>
