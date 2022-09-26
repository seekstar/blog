---
title: Linux查看汇编码对应的源代码
date: 2022-09-17 15:21:49
tags:
---

例如这个`objdump.c`：

```c
#include <stdio.h>

int main() {
	printf("Hello world!\n");

	return 0;
}
```

编译选项中加入`-g`编译：`gcc objdump.c -g -o objdump`。

然后查看编译结果的汇编码：`objdump -gS -D nova.ko`

```text
0000000000001139 <main>:
#include <stdio.h>

int main() {
    1139:       55                      push   %rbp
    113a:       48 89 e5                mov    %rsp,%rbp
        printf("Hello world!\n");
    113d:       48 8d 05 c0 0e 00 00    lea    0xec0(%rip),%rax        # 2004 <_IO_stdin_u
sed+0x4>
    1144:       48 89 c7                mov    %rax,%rdi
    1147:       e8 e4 fe ff ff          call   1030 <puts@plt>

        return 0;
    114c:       b8 00 00 00 00          mov    $0x0,%eax
}
    1151:       5d                      pop    %rbp
    1152:       c3                      ret
```

可以看到`113d`到`1147`对应`printf("Hello world!\n");`

参考：

<https://stackoverflow.com/questions/2511018/how-does-objdump-manage-to-display-source-code-with-the-s-option>

<https://www.opensourceforu.com/2011/01/understanding-a-kernel-oops/>

报错信息里，`my_oops_init+0x12/0x21`的含义是`<symbol> + the offset/length`。
