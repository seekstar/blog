---
title: conan学习笔记
date: 2023-05-16 13:14:02
tags:
---

官方教程：

<https://docs.conan.io/2/tutorial.html>

<https://docs.conan.io/2/tutorial/developing_packages/local_package_development_flow.html>

## 配置默认设置

```shell
conan profile detect
vim ~/.conan2/profiles/default
```

## 创建包

在工程的根目录下执行：

```shell
conan new cmake_exe -d name=包名 -d version=0.1.0
```

如果是库的话：

```shell
conan new cmake_lib -d name=包名 -d version=0.1.0
```

然后编辑`CMakeLists.txt`和`conanfile.py`。

### `conanfile.py`

#### requirements

定义包的依赖。例子：

```py
def requirements(self):
    self.requires("rusty-cpp/[>=0.1.1]")
    # 0.1.x都行
    self.requires("rcu-vector/[~0.1]")
```

官方文档：<https://docs.conan.io/2/tutorial/versioning/version_ranges.html#range-expressions>

#### generate

在`conan install`的时候被调用，用于生成用于编译的文件。

#### build

在`conan build`的时候被调用，用于编译。

#### package

在打包的时候被调用。

#### package_info

提供包的各种信息，供其他包使用。

`cpp_info.libs`: 此包提供的其他包应该链接的库，通常放在`libs`文件夹里。

`cpp_info.system_libs`: 此包依赖的系统库。依赖此包的其他包会继承此依赖。

参考：[question: difference between "cpp_info.libs" and "cpp_info.system_libs"](https://github.com/conan-io/conan/issues/8104)

`cpp_info.set_property("cmake_target_name", "xxxx")`: 给出这个库的cmake target的名字。这样依赖这个库的其他包在它自己的`CMakeLists.txt`里用`find_package`找这个包之后就能用这个包里给出的target了。

参考：<https://docs.conan.io/2/tutorial/creating_packages/define_package_information.html>

## 生成用于编译的辅助文件

```shell
conan install .
```

默认生成在`build`目录下面。

## 编译

```shell
conan build .
```

如果之前没有执行`conan install .`的话会自动执行`conan install .`。

## 打包并添加到local cache

```shell
conan create .
```

如果之前没有执行`conan build .`的话会自动执行之。

## 例子

### 只有头文件的包 (header-only)

例子：<https://github.com/seekstar/rusty-cpp>

`CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.15)
project(rusty-cpp CXX)

add_library(rusty-cpp INTERFACE)
target_include_directories(rusty-cpp INTERFACE include)

# https://stackoverflow.com/a/59257505
file(GLOB_RECURSE RUSTY_HEADERS "include/rusty/*")
# PUBLIC_HEADER会被install
set_target_properties(rusty-cpp PROPERTIES PUBLIC_HEADER "${RUSTY_HEADERS}")

# 这里要设置DESTINATION，不然install的时候会直接被copy到include目录下面。
install(TARGETS rusty-cpp DESTINATION "include/rusty")
```

`conanfile.py`的关键部分：

```py
def package_info(self):
    # 让依赖这个包的其他包知道这个包对应的CMake target叫什么名字
    self.cpp_info.set_property("cmake_target_name", "rusty-cpp")
    # For header-only packages, libdirs and bindirs are not used
    # so it's necessary to set those as empty.
    self.cpp_info.libdirs = []
    self.cpp_info.bindirs = []
```

参考：<https://docs.conan.io/2/tutorial/creating_packages/other_types_of_packages/header_only_packages.html>

### 含多个库的包 (package with multiple libraries)

<https://docs.conan.io/2/examples/conanfile/package_info/components.html#examples-conanfile-package-info-components>

### 只有头文件的含多个库的包 (header-only package with multiple libraries)

例子：<https://github.com/seekstar/rcu-vector>

坑点：如果库`a`是header-only的话，不能把自己（也就是`a`）放进`self.cpp_info.components['a'].libs`，因为`libs`表示依赖这个库的其他库需要链接的库，而header-only的库不能被链接。

## 将变量传给cmake

网上通常说是通过`cmake.definitions`：[passing command line arguments to cmake during conan build](https://github.com/conan-io/conan/issues/4572)

但是在conan2上会报这个错：`AttributeError: 'CMake' object has no attribute 'definitions'`

实际上应该用cmake.configure的cli_args参数把变量传给cmake：

```py
    options = {
        "ARG1": ["ANY"],
        "ARG2": ["ANY"],
    }

    def build(self):
        cmake = CMake(self)
        cli_args=[
            "-DARG1=" + str(self.options.ARG1),
            "-DARG2=" + str(self.options.ARG2),
        ]
        cmake.configure(cli_args=cli_args)
        cmake.build()
```

参考：<https://docs.conan.io/2/reference/tools/cmake/cmake.html#conan.tools.cmake.cmake.CMake.configure>
