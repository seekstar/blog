---
title: C语言调用Rust
date: 2022-09-02 13:19:03
tags:
---

比方说要把这个函数暴露给C语言使用：

```rust
fn add(a: i32, b: i32) -> i32 {
    return a + b;
}
```

```shell
cargo new add --lib
```

在`add/src/lib.rs`里写入：

```rust
#[no_mangle]
pub extern "C" fn add(a: i32, b: i32) -> i32 {
    return a + b;
}
```

其中`#[no_mangle]`表示使得这个函数的符号保持为函数名，而不要加入参数类型之类的乱七八糟的。

`extern "C"`表示使用C语言的ABI，这样C语言就能直接调用这个函数了。

然后在`add/Cargo.toml`里加入：

```toml
[lib]
crate-type = ["staticlib", "dylib"]
```

表示同时编译出静态库和动态库。

然后新建文件`add/include/add.h`，用来提供C语言的接口：

```c
extern int add(int a, int b);
```

然后就完成了。现在试着编译一下：

```shell
cd add
cargo build
ls target/debug
```

就可以在`target/debug`下面看到静态库`libadd.a`和动态库`libadd.so`。

现在测试一下。在`add`目录的旁边新建一个`test.c`：

```c
#include <stdio.h>
#include "add.h"

int main() {
 printf("%d\n", add(1, 2));
 return 0;
}
```

编译运行：

```shell
gcc test.c -I add/include/ -L"add/target/debug/" -l add -o test
LD_LIBRARY_PATH=add/target/debug/ ./test
```

成功输出`3`。
