---
title: "systemtap semantic error: no match (similar functions:"
date: 2020-12-27 00:43:39
---

用户态probe文档：<https://sourceware.org/systemtap/SystemTap_Beginners_Guide/userspace-probing.html>

这是`process("PATH").function("function")`报的错，意思是没有在ELF文件中找到这个函数对应的符号。大概率是因为ELF文件是用C++编译来的，符号名跟函数名不对应。

例如对于以下程序：

```c
#include <stdio.h>

void fun() {
	printf("Hello\n");
}
int main() {
	fun();
	return 0;
}
```

保存为`test.c`

## C

```shell
gcc test.c -o test
objdump -D test | grep fun
```

输出的结果是

```text
000000000000063a <fun>:
 656:   e8 df ff ff ff          callq  63a <fun>
```

## C++

用g++编译

```shell
g++ test.c -o test
objdump -D test | grep fun
```

输出的结果是

```text
000000000000063a <_Z3funv>:
 651:   e8 e4 ff ff ff          callq  63a <_Z3funv>
```
可以看到符号变成了`_Z3funv`
就很恶心

## rust

rust也有这种问题（但是可以解决）。

```rs
fn fun() {
    print!("Hello rust\n");
}
fn main() {
    fun();
}
```

```shell
rustc test.rs
objdump -D test | grep rs_fun
```

```text
0000000000004700 <_ZN4test6rs_fun17he2386bae0dbca493E>:
    4751:       e8 aa ff ff ff          callq  4700 <_ZN4test6rs_fun17he2386bae0dbca493E>
    4695:       73 74                   jae    470b <_ZN4test6rs_fun17he2386bae0dbca493E+0xb>
    46a0:       73 5f                   jae    4701 <_ZN4test6rs_fun17he2386bae0dbca493E+0x1>
```

可以看到符号也与函数名不对应。
但是rust可以通过使用`no_mangle`选项来强制让符号和函数名一致。（参考：<https://zhuanlan.zhihu.com/p/70095462>）

```rs
#[no_mangle]
fn rs_fun() {
    print!("Hello rust\n");
}
fn main() {
    rs_fun();
}
```

```shell
rustc good.rs
objdump -D good | grep rs_fun
```

```text
00000000000046c0 <rs_fun>:
    4711:       e8 aa ff ff ff          callq  46c0 <rs_fun>
    46d7:       00 05 00 00 00 00       add    %al,0x0(%rip)        # 46dd <rs_fun+0x1d>
    464f:       65 64 4f 75 74          gs fs rex.WRXB jne 46c8 <rs_fun+0x8>
```

这样就好了。
