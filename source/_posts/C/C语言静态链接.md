---
title: C语言静态链接
date: 2022-09-02 22:23:45
tags:
---

相关：{% post_link C/'C语言动态链接库' %}

## 场景

`add.c`:

```c
int add(int a, int b) {
    return a + b;
}
```

`sub.c`:

```c
int sub(int a, int b) {
    return a - b;
}
```

`main.c`:

```c
#include <stdio.h>

int add(int, int);
int sub(int, int);

int main() {
    printf("%d, %d\n", add(1, 2), sub(1, 2));

    return 0;
}
```

利用静态链接在`main.c`中使用`add.c`和`sub.c`中的`add`和`sub`函数。

## 生成`libmath.a`

```shell
# add.o
gcc -c add.c
# sub.o
gcc -c sub.c
# libmath.a
ar -rc libmath.a add.o sub.o
```

## 生成`main`

```shell
gcc -c main.c
gcc main.o libmath.a -o main
```

或者一步到位：

```shell
gcc main.c libmath.a -o main
```

## 运行

`add`和`sub`已经被静态链接到`main`里了，所以直接运行即可：

```shell
./main
```

输出：

```text
3, -1
```

## 参考

<https://blog.csdn.net/m0_60073820/article/details/121385752>
