---
title: linux perf得到完整调用关系
date: 2021-09-20 10:38:42
---

一般情况下，在高优化等级时，编译器会把栈帧破坏掉，导致生成的火焰图调用关系是错误的。因此我们需要用编译选项`-fno-omit-frame-pointer`编译自己的代码，从而使得自己的代码不破坏栈帧。

由于系统库通常是采用高优化等级编译的，因此调用系统库函数时仍然会破坏栈帧。这时需要用`-fno-omit-frame-pointer`重新编译系统库。

## `glibc`

### 安装依赖

可以用nix安装，不需要root权限：

```shell
nix-env -iA nixpkgs.bison
```

Nix包管理器安装和使用教程：{% post_link Distro/'使用国内源安装和使用Nix包管理器' %}

### 获取源码

glibc每六个月发布类似于2.31这样的minor version，然后在这里fork出这个minor version的branch，比如`release/2.31/master`，以后的bug fix都commit到这个branch上，不再单独发布bug fix version。因此我们可以先clone glibc的repo，然后checkout到目标minor version的branch即可。

我的系统上glibc版本是`2.31-13+deb11u7`，所以这里获取`2.31`的源码：

```shell
git clone https://mirrors.tuna.tsinghua.edu.cn/git/glibc.git
cd glibc
git checkout release/2.31/master
```

### 编译

```shell
mkdir -p build
cd build
CFLAGS='-O2 -fno-omit-frame-pointer'
CXXFLAGS='-O2 -fno-omit-frame-pointer'
../configure --prefix=$HOME/no-omit-frame-pointer CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS"
make -j$(nproc)
make install
cd ../..
```

这里面包含了这些库：

```text
ld-linux-x86-64.so.2
libc.so
libm.so
libpthread.so.0
```

## `gcc`

如果要编译C++程序的话，还需要编译`gcc`，因为`libstdc++`是`gcc`提供的。

### 获取源码

gcc的功能更新会更新major version，后面的minor version都是bug fix version，官方文档：<https://gcc.gnu.org/develop.html>

我的系统上的gcc版本是`10.2.1`，所以这里编译安装它的最新bug fix版本`10.5.0`:

```shell
wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-10.5.0/gcc-10.5.0.tar.gz
tar xzf gcc-10.5.0.tar.gz
cd gcc-10.5.0
```

或者也可以用git获取最新的bug fix版本：

```shell
git clone https://mirrors.tuna.tsinghua.edu.cn/git/gcc.git
cd gcc
git checkout releases/gcc-10
```

### 下载依赖

```shell
./contrib/download_prerequisites
```

### 用系统自带的glibc编译

理论上这里使用刚刚编译的glibc编译gcc最好，但是这需要使用交叉编译的方法，太复杂了，我试了很久都没有成功。由于我们之前编译安装的glibc跟系统里自带的glibc是兼容的（只是修了一些BUG），所以这里可以直接用系统自带的glibc编译。

```shell
mkdir -p build
cd build
export CFLAGS="-O2 -fno-omit-frame-pointer"
export CXXFLAGS=$CFLAGS
../configure --disable-multilib --enable-languages=c,c++ --prefix=$HOME/no-omit-frame-pointer
make -j$(nproc)
make install
cd ../..
```

参考：[How to edit and re-build the GCC libstdc++ C++ standard library source?](https://stackoverflow.com/a/51946224/13688160)

## 编译选项

以后我们用这套编译选项来编译其他软件：

```shell
INSTALL_ROOT=$HOME/no-omit-frame-pointer
export CC=$INSTALL_ROOT/bin/gcc
export CXX=$INSTALL_ROOT/bin/g++
export CFLAGS="-O2 -fno-omit-frame-pointer"
export CXXFLAGS=$CFLAGS
export LDFLAGS="-Wl,-rpath=$INSTALL_ROOT/lib -Wl,-rpath=$INSTALL_ROOT/lib64 -Wl,--dynamic-linker=$INSTALL_ROOT/lib/ld-linux-x86-64.so.2"
```

`-Wl,-rpath`: <https://stackoverflow.com/a/6562437/13688160>

`-Wl,--dynamic-linker`: [Specifying the dynamic linker / loader to be used when launching an executable on Linux](https://stackoverflow.com/a/25355236/13688160)

## 常见库的编译

先export上面说的编译选项，然后就可以用正常的方法编译了。

### `libgflags`

```shell
git clone https://github.com/gflags/gflags.git
cd gflags
mkdir -p build
cd build
cmake .. -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$INSTALL_ROOT
make -j$(nproc)
make install
cd ../..
```

## 编译目标应用

### 直接使用gcc

`hello.c`:

```c
#include <stdio.h>                                                                 
int main() {                                                                       
        printf("Hello world!\n");                                                      
        return 0;                                                                      
}
```

```shell
$CC hello.c -o hello $CFLAGS $LDFLAGS
ldd hello
./hello
```

```text
        linux-vdso.so.1 (0x00007ffc37f52000)
        libc.so.6 => /home/searchstar/no-omit-frame-pointer/lib/libc.so.6 (0x00007f2d2bce3000)
        /home/searchstar/no-omit-frame-pointer/lib/ld-linux-x86-64.so.2 => /lib64/ld-linux-x86-64.so.2 (0x00007f2d2beb8000)
Hello world!
```

可以看到这里用的是我们自己编译的glibc

参考：

[Where is linux-vdso.so.1 present on the file system](https://stackoverflow.com/questions/58657036/where-is-linux-vdso-so-1-present-on-the-file-system)

### 直接使用g++

`hello.cpp`:

```cpp
#include <iostream>
int main() {
        std::cout << "Hello world!" << std::endl;
        return 0;
}
```

```shell
$CXX hello.cpp -o hello $CXXFLAGS $LDFLAGS
ldd hello
./hello
```

```text
        linux-vdso.so.1 (0x00007ffff89fe000)
        libstdc++.so.6 => /home/searchstar/no-omit-frame-pointer/lib64/libstdc++.so.6 (0x00007f650bbc6000)
        libm.so.6 => /home/searchstar/no-omit-frame-pointer/lib/libm.so.6 (0x00007f650ba85000)
        libgcc_s.so.1 => /home/searchstar/no-omit-frame-pointer/lib64/libgcc_s.so.1 (0x00007f650ba6b000)
        libc.so.6 => /home/searchstar/no-omit-frame-pointer/lib/libc.so.6 (0x00007f650b89d000)
        /home/searchstar/no-omit-frame-pointer/lib/ld-linux-x86-64.so.2 => /lib64/ld-linux-x86-64.so.2 (0x00007f650bd9c000)
Hello world!
```

## 采样

```shell
perf record --call-graph=fp 命令 参数...
```

然后生成火焰图：{% post_link Linux/'perf.data生成火焰图' %}

## 不推荐：`--call-graph=dwarf`

如果不想重新编译系统库的话，可以使用linux perf的`--call-graph=dwarf`，这样perf会把一部分栈内存保存下来，然后通过后处理来unwind，从而得到调用栈。但是这种方法仍然存在调用关系错乱的问题，而且采样的时间开销和空间开销很大，采样频率需要稍微调低一点。

参考文献：

<https://users.rust-lang.org/t/opt-level-2-removes-debug-symbols-needed-in-perf-profiling/16835/7>

<https://stackoverflow.com/questions/57430338/what-do-the-perf-record-choices-of-lbr-vs-dwarf-vs-fp-do>

## 相关

[Consider not omitting frame pointers by default on targets with many registers](https://gcc.gnu.org/bugzilla//show_bug.cgi?id=100811)
