---
title: conan学习笔记
date: 2023-05-16 13:14:02
tags:
---

官方教程：

<https://docs.conan.io/2/tutorial.html>

<https://docs.conan.io/2/tutorial/developing_packages/local_package_development_flow.html>

## 安装

官方教程：<https://docs.conan.io/2/installation.html>

```shell
pip3 install --upgrade conan
```

## 配置默认设置

```shell
conan profile detect
vim ~/.conan2/profiles/default
```

我的偏好：

```shell
compiler.cppstd=17
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
    # https://semver.npmjs.com/
    # 0.2.3, 0.2.4 等都行，但 0.1.x 和 0.3.x 不行
    self.requires("包名/[^0.2.3]")
    # 0.1.1, 0.1.2, 0.2.x, 0.3.x 都行
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

### 例子

#### 生成可执行文件的包

`CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.15)
project(包名 CXX)

# https://seekstar.github.io/2023/09/24/cmake打印导入的包中的warning/
set(CMAKE_NO_SYSTEM_FROM_IMPORTED TRUE)

find_package(依赖1 CONFIG REQUIRED)
find_package(依赖2 CONFIG REQUIRED)

aux_source_directory(src SRCS)
add_executable(${PROJECT_NAME} ${SRCS})

target_link_libraries(${PROJECT_NAME}
	PUBLIC
		依赖1
		依赖2
)
```

`conanfile.py`:

```py
from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout, CMakeDeps

class 下划线包名Recipe(ConanFile):
    name = "包名"
    version = "0.1.0"

    # Optional metadata
    license = ""
    author = "姓名 邮箱"
    url = "https://github.com/用户名/仓库名"
    description = ""
    topics = ("关键词1", "关键词2", "关键词3")

    # Binary configuration
    settings = "os", "compiler", "build_type", "arch"

    def requirements(self):
        self.requires("rusty-cpp/[>=0.1.5]")

    def layout(self):
        cmake_layout(self)

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)
        tc.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
```

#### 只有头文件的包 (header-only)

文档：<https://docs.conan.io/2/tutorial/creating_packages/other_types_of_packages/header_only_packages.html>

完整工程：<https://github.com/seekstar/counter-timer-cpp>

`CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.15)
project(包名 CXX)

# 为了兼容git submodule
# https://seekstar.github.io/2023/08/25/cmake-find-package兼容add-subdirectory/
if (NOT TARGET 依赖1)
	find_package(依赖1 CONFIG REQUIRED)
endif()
if (NOT TARGET 包2里的依赖2)
	find_package(包2 CONFIG REQUIRED COMPONENTS 依赖2)
endif()

add_library(${PROJECT_NAME} INTERFACE)
target_include_directories(${PROJECT_NAME} INTERFACE include)

# https://stackoverflow.com/a/59257505
file(GLOB_RECURSE HEADERS "include/*")
# PUBLIC_HEADER会被install
set_target_properties(${PROJECT_NAME} PROPERTIES PUBLIC_HEADER "${HEADERS}")
target_link_libraries(${PROJECT_NAME}
	INTERFACE
		依赖1
		依赖2
)

# 这里要设置DESTINATION，不然install的时候会直接被copy到include目录下面。
install(TARGETS ${PROJECT_NAME} DESTINATION "include/")
```

`conanfile.py`:

```py
from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout, CMakeDeps

class 下划线包名Recipe(ConanFile):
    name = "包名"
    version = "0.1.0"

    # Optional metadata
    license = ""
    author = "姓名 邮箱"
    url = "https://github.com/用户名/仓库名"
    description = ""
    topics = ("关键词1", "关键词2", "关键词3")

    # Binary configuration
    settings = "build_type"

    # Sources are located in the same place as this recipe, copy them to the recipe
    exports_sources = "CMakeLists.txt", "include/*"
    # We can avoid copying the sources to the build folder in the cache
    no_copy_source = True

    def requirements(self):
        self.requires("依赖1/[>=xx.xx.xx]")
        self.requires("包2/[~xx.xx]")

    def layout(self):
        cmake_layout(self)

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)
        tc.generate()

    def package(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.install()

    def package_info(self):
        # 让依赖这个包的其他包知道这个包对应的CMake target叫什么名字
        self.cpp_info.set_property("cmake_target_name", "CMakeTarget名字")
        # For header-only packages, libdirs and bindirs are not used
        # so it's necessary to set those as empty.
        self.cpp_info.libdirs = []
        self.cpp_info.bindirs = []
```

#### 含多个库的包 (package with multiple libraries)

<https://docs.conan.io/2/examples/conanfile/package_info/components.html#examples-conanfile-package-info-components>

#### 只有头文件的含多个库的包 (header-only package with multiple libraries)

例子：<https://github.com/seekstar/rcu-vector>

坑点：如果库`a`是header-only的话，不能把自己（也就是`a`）放进`self.cpp_info.components['a'].libs`，因为`libs`表示依赖这个库的其他库需要链接的库，而header-only的库不能被链接。

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

Debug版本：

```shell
conan create . -s build_type=Debug
```

从local cache删除：

```shell
conan remove 包名/x.x.x@
```

详见官方文档：<https://docs.conan.io/1/reference/commands/misc/remove.html>

## `conan.lock`

固定所有依赖版本，避免未来有依赖更新之后无法编译。注意，只有当前包是end product的时候才能锁依赖版本。如果当前包是一个库，就不应该锁依赖版本，因为使用这个库的包可能想用别的版本。

创建`conan.lock`:

```shell
conan lock create .
```

创建完了之后好像会自动被用上。

从`conan.lock`中清楚unused locked versions：

```shell
conan lock create . --lockfile-clean
```

官方文档：<https://docs.conan.io/2/tutorial/versioning/lockfiles.html>

## Conan server

可以自己部署一个conan server并将打好的包上传上去，方便团队协作。

官方教程太简略了：<https://docs.conan.io/2/tutorial/conan_repositories/setting_up_conan_remotes/conan_server.html#conan-server>

### 安装

```shell
pip3 install conan-server
```

### 配置

官方文档：<https://docs.conan.io/2/reference/conan_server.html>

编辑`~/.conan_server/server.conf`。一些比较重要的项如下。

#### `[users]`

格式是`用户名: 密码`。密码是明文保存的，差评。

安全起见，建议把`demo: demo`删掉，换上自己的。

#### `[write_permissions]`

默认为空。虽然上面的注释说author可以write自己的包，但是好像没法上传新的包。所以我直接设置成了所有已登录用户都可以写：

```text
*/*@*/*: ?
```

### 运行

```shell
conan_server
```

### 添加到remote list

```shell
conan remote add remote名字 http://localhost:9300
```

删除：`conan remote remove remote名字`

### 登录

```shell
conan remote login remote名字 用户名
```

或者直接提供密码：

```shell
conan remote login remote名字 用户名 -p 密码
```

### 上传

官方文档：<https://docs.conan.io/2/tutorial/conan_repositories/uploading_packages.html>

```shell
conan upload 包名 -r=remote名
```

注意这里只上传已经构建的版本。所以最好先构建release和debug，再把它们一起上传：

```shell
conan create . && conan create . -s build_type=Debug
conan upload 包名 -r=remote名
```

### 搜索包

这里列出所有包：

```shell
conan search "*" -r=remote名
```

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

## 已知的问题

### 测试

```shell
conan test test_package 包名/版本 --build missing
```

其中`包名/版本`不可忽略。感觉应该默认为当前包的最新版本。

此外，没找到怎么直接在`conan test`的时候把参数传进去。好像只能通过直接运行`./test_package/build/gcc-10-x86_64-17-release/test 参数1 参数2`来传参。

### 与conan2不兼容的包

(2023.07.07) [userspace-rcu](https://conan.io/center/userspace-rcu)

### 会自动使用用`nix-env`安装的库

比如用`nix-env`安装了gflags之后，conan会自动使用它，但是与此同时会使用系统安装的glibc。但是`nix-env`安装的gflags通常依赖高版本的glibc，如果系统里自带的glibc版本过低，就会报链接错误。这时只需要`nix-env -e gflags`，让conan使用系统自带的gflags即可。
