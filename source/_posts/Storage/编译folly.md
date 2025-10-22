---
title: 编译folly
date: 2025-10-21 17:19:14
tags:
---

在这里选择要安装的版本：<https://github.com/facebook/folly/releases>

```shell
git clone https://github.com/facebook/folly
cd folly
git checkout v2025.10.20.00
```

## （可选）虚拟环境

如果需要特定版本的编译器或者python包，建议安装在虚拟环境里。

```shell
mkdir ~/.venvs/folly
python3 -m venv ~/.venvs/folly
. ~/.venvs/folly/bin/activate
```

## GCC 13

不兼容GCC 14，会报错：

```text
.../folly/folly/container/test/ForeachTest.cpp:318:39: error: use of built-in trait ‘__type_pack_element<I, T ...>’ in function signature; use library traits instead
  318 |   static type_pack_element_t<I, T...> elem;
      |                                       ^~~~
```

看起来是因为folly用了编译器private的东西，gcc14会报错：<https://github.com/facebook/folly/issues/2493>

这个PR旨在修复这个问题，但还没合进去：<https://github.com/facebook/folly/pull/2499>

所以如果系统的`g++`是g++-14，要换成g++-13：

```shell
sudo apt install -y g++-13
export CC=gcc-13
export CXX=g++-13
```

但是不知道为什么boost编译的时候还是会用默认的g++，导致后面会报这个错误：

```text
extracted/boost-boost_1_83_0.tar.gz/boost_1_83_0/libs/filesystem/src/directory.cpp:1348:(.text.unlikely+0x3da): undefined reference to `__cxa_call_terminate'
```

根据<https://forums.gentoo.org/viewtopic-t-1172390-start-0.html>，应该是因为之前boost用的GCC 14，但其他的用的GCC 13。所以还需要在虚拟环境里创建到gcc-13和g++-13的符号链接，让boost编译的时候也用GCC 13：

```shell
ln -s /usr/bin/g++-13 ~/.venvs/folly/bin/g++
ln -s /usr/bin/gcc-13 ~/.venvs/folly/bin/gcc
```

## numpy 1.0

不兼容`numpy 2.0`，会报错：

```text
libs/python/src/numpy/dtype.cpp: In member function ‘int boost::python::numpy::dtype::get_itemsize() const’:
libs/python/src/numpy/dtype.cpp:101:83: error: ‘PyArray_Descr’ has no member named ‘elsize’
  101 | int dtype::get_itemsize() const { return reinterpret_cast<PyArray_Descr*>(ptr())->elsize;}
      |                                                                                   ^~~~~~
```

需要安装`numpy 1.0`

```shell
# 可以在虚拟环境里安装
pip3 install numpy~=1.0
# 要编译一段时间
```

Update: 好像把numpy卸掉也行？

## 安装其他依赖

```shell
sudo apt install -y libssl-dev
```

## 编译

默认会把编译过程中生成的文件放在`/tmp`下面，但是有些服务器`/tmp`是tmpfs，容量有限，编译生成的文件很容易占满`/tmp`。所以这里把编译过程中生成的文件放在`$workspace/build`。

```shell
# 根据自己的系统选择。Debian 12是python3.11。Debian 13是python3.13
python=python3.13
CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu/$python/:/usr/include/$python/:$CPLUS_INCLUDE_PATH python3 ./build/fbcode_builder/getdeps.py --scratch-path=$workspace/build --install-prefix=$workspace/deps build
```

然后就安装到了`$workspace/deps`。

以后用之前把这个目录加到cmake搜索目录即可：

```shell
export CMAKE_PREFIX_PATH=$workspace/deps:$CMAKE_PREFIX_PATH
```

Debian 12和13在后续使用的时候会报这个错：

```text
/usr/bin/ld: cannot find -lgflags_shared: No such file or directory
```

根据这个issue: <https://github.com/facebook/folly/issues/1932>，应该在`$workspace/deps/folly/lib/cmake/folly/folly-targets.cmake`里把`gflags_shared`改成`gflags::gflags_shared`
