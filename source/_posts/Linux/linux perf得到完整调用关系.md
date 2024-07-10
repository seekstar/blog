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

debian 12上glibc版本是`2.36-9+deb12u7`，所以应该获取`2.36`的源码。
debian 11上glibc版本是`2.31-13+deb11u7`，应该获取`2.31`的源码。

```shell
git clone https://mirrors.tuna.tsinghua.edu.cn/git/glibc.git
cd glibc
git checkout release/2.36/master
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

debian 12 上的gcc版本是`12.2.0-14`，这里应该编译安装它的最新bug fix版本`12.4.0`。
debian 11 上的gcc版本是`10.2.1`，这里应该编译安装它的最新bug fix版本`10.5.0`。

```shell
version=12.4.0
wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-$version/gcc-$version.tar.gz
tar xzf gcc-$version.tar.gz
cd gcc-$version
```

或者也可以用git获取最新的bug fix版本：

```shell
git clone https://mirrors.tuna.tsinghua.edu.cn/git/gcc.git
cd gcc
git checkout releases/gcc-10
```

### 安装依赖

```shell
sudo apt install libgmp-dev libmpfr-dev libmpc-dev 
```

或者自动下载安装依赖：

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
unset LD_LIBRARY_PATH
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

### `liburcu`

官网：<https://liburcu.org/>

Debian 12上版本是`0.13.2-1`，所以这里应该下载安装0.13.3
Debian 11上版本是`0.12.2-1`，所以这里应该下载安装0.12.5

```shell
version=0.13.3
wget https://lttng.org/files/urcu/userspace-rcu-$version.tar.bz2
tar xjf userspace-rcu-$version.tar.bz2
cd userspace-rcu-$version
mkdir build
cd build
../configure --prefix=$INSTALL_ROOT
make -j$(nproc)
make install
cd ../..
```

### `boost`

官网：<https://www.boost.org/>

Debian 11和Debian 12的版本都是`1.74.0.3`，所以这里应该安装`1.74.0`。

编译安装教程：<https://www.boost.org/doc/libs/1_74_0/more/getting_started/unix-variants.html>

```shell
wget https://archives.boost.io/release/1.74.0/source/boost_1_74_0.tar.bz2
tar xjf boost_1_74_0.tar.bz2
cd boost_1_74_0
./bootstrap.sh --prefix=$INSTALL_ROOT
# 让b2用我们编译的gcc
export PATH=$INSTALL_ROOT/bin:$PATH
```

编译安装所有库：

```shell
./b2 --prefix=$INSTALL_ROOT install link=shared cflags="$CFLAGS" cxxflags="$CXXFLAGS" linkflags="$LDFLAGS"
```

也可以选择性编译安装某些库。查看有哪些库：

```shell
./b2 --show-libraries
```

编译安装某个库，比如`program_options`，加上`--with-program_options`即可：

```shell
./b2 --with-program_options --prefix=$INSTALL_ROOT install link=shared cflags="$CFLAGS" cxxflags="$CXXFLAGS" linkflags="$LDFLAGS"
```

文档写的`--with-libraries=library-name-list`应该是`bootstrap.sh`的参数，没试过。

参考：<https://stackoverflow.com/questions/6945012/passing-compiler-flags-to-boost-libraries-such-as-thread-which-require-compila>

### `xxhash`

```shell
wget https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.2.tar.gz
tar xzf v0.8.2.tar.gz
cd xxHash-0.8.2/
make -j$(nproc)
make install PREFIX=$INSTALL_ROOT
cd ..
```

### `liburing`

Debian 12上的版本是`2.3-3`，所以应该安装`2.3`。

```shell
wget https://git.kernel.dk/cgit/liburing/snapshot/liburing-2.3.tar.bz2
tar xjf liburing-2.3.tar.bz2
cd liburing-2.3/
./configure --prefix=$INSTALL_ROOT
make -j$(nproc)
make install
cd ..
```

### `tbb`

```shell
wget https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2021.13.0.tar.gz
tar xzf v2021.13.0.tar.gz
cd oneTBB-2021.13.0/
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_ROOT -DTBB_TEST=OFF
make -j$(nproc)
make install
cd ..
```

## （可选）打包`no-omit-frame-pointer`编译环境

可以在一台机器上把`no-omit-frame-pointer`的编译器和常见库都编译好，然后打包到别的机器上使用。但是要注意在目标机器解压后需要修改一下rpath：

```shell
cd no-omit-frame-pointer
find . -name "lib*.so*" -exec patchelf {} --set-rpath "$(pwd)/lib:$(pwd)/lib64" \;
```

参考：{% post_link C/'解决找不到RUNPATH下的库的问题' %}

## 编译目标应用

### CMake项目

export上面说的编译选项后就可以照常编译了。

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
