---
title: C语言动态链接库
date: 2020-03-26 21:38:46
---

详细知识点：<https://www.bilibili.com/read/cv269765/?tdsourcetag=s_pctim_aiomsg>

使用gcc。

## 场景

add.c

```c
int add(int a, int b) {
	return a + b;
}
```

sub.c

```c
int sub(int a, int b) {
	return a - b;
}
```

main.c

```c
#include <stdio.h>

int add(int, int);
int sub(int, int);

int main() {
	printf("%d, %d\n", add(1, 2), sub(1, 2));

	return 0;
}
```

利用动态链接在main.c中使用add.c和sub.c中的add和sub函数。

## windows

windows的动态链接库的后缀名一般叫做dll（Dynamic Link Library）。

以下命令都是在powershell里运行的。

### 创建mymath.def

```text
LIBRARY mymath.dll
EXPORTS
add
sub
```

### 得到mymath.exp和mymath.lib

其中mymath.exp是导出符号表，定义哪些符号需要导出。mymath.lib是导入符号表，定义哪些符号需要导入。

```shell
dlltool --input-def=mymath.def --output-exp=mymath.exp --output-lib=mymath.lib
```

可以简写成

```shell
dlltool -d mymath.def -e mymath.exp -l mymath.lib
```

### 生成mymath.dll

```shell
gcc -c add.c
gcc -c sub.c
gcc --shared mymath.exp add.o sub.o -o mymath.dll
```

可以理解为利用导出符号表mymath.exp来把add.o和sub.o中无用的符号都弄掉，只保留要导出的符号。

### 生成main.exe

```shell
gcc -c main.c
gcc main.o mymath.lib -o main.exe
```

可以理解为利用导入符号表告诉链接器这些符号可以在运行时动态导入，不需要静态链接这个符号了。

或者直接使用mymath.dll

```shell
gcc main.c mymath.dll -o main
```

### 运行

要确保mymath.dll与可执行文件在同一目录或者在`C:\Windows\System32\`

```shell
.\main.exe
```

输出

```text
3, -1
```

## linux

参考：<https://www.cnblogs.com/zuofaqi/p/10440754.html>
linux的动态链接库叫共享库，后缀名一般是so（Shared Object）。
先编辑好add.c、sub.c、mymath.def、main.c。

### 生成libmymath.so

```shell
gcc -fPIC -c add.c
gcc -fPIC -c sub.c
```

PIC: Position Independent Code

```shell
gcc -shared sub.o add.o -o libmymath.so
```

shared: 生成动态库而不是可执行文件

合并成一个命令：

```shell
gcc -fPIC -shared sub.c add.c -o libmymath.so
```

### 生成main

如果libmymath.so在当前目录，则

```shell
gcc -c main.c
gcc main.o -L. -lmymath -o main
```

或者一步到位：

```shell
gcc main.c -L. -lmymath -o main
```

`-L.`的作用是让操作系统在当前目录下找libmymath.so。
如果libmymath.so在共享库目录如`/lib`里，就不需要`-L.`。

```shell
gcc main.c -lmymath -o main
```

### 运行

操作系统要找到libmymath.so，才能在运行时将其链接到main上。windows中当动态链接库与可执行文件在同一目录下时便会自动链接上，但是linux中只会去共享库目录下去找。

让操作系统找到libmymath.so有几种方法：

- 直接把它放到/lib或者/usr/lib里
- 如果只是需要临时起效，可以这样把环境变量LD_LIBRARY_PATH设置到libmymath.so所在目录，例如

```shell
LD_LIBRARY_PATH=~/lib ./main
```

或者

```shell
export LD_LIBRARY_PATH=~/lib
./main
```

- 编辑/etc/ld.so.conf文件，加入libmymath.so所在目录的绝对路径，然后`sudo ldconfig`重建/etc/ld.so.cache
