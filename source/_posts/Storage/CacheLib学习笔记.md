---
title: CacheLib学习笔记
date: 2023-11-22 17:33:09
tags:
---

## 编译

官方编译教程：<https://cachelib.org/docs/installation/>

Debian 11上的liburing版本是0.7-3，好像太老了，编译会报错

```text
error: ‘IORING_SETUP_SQE128’ was not declared in this scope
```

把它删掉就好了：

```shell
sudo apt remove liburing1 liburing-dev
```

然后编译：

```shell
./contrib/build.sh -j
```

编译结果默认存在`./opt/cachelib`里。如果要编译安装到另一个目录，比如`$HOME/opt/cachelib`：

```shell
./contrib/build.sh -j -p $HOME/opt/cachelib
```

注意，编译安装好了之后是不能移动的，因为里面有些so文件中硬编码了RUNPATH，比如：

```text
% readelf -d libthriftprotocol.so.1.0.0 | grep PATH
 0x000000000000001d (RUNPATH)            Library runpath: [/home/searchstar/opt/cachelib/lib:/usr/local/lib]
```

移动了位置之后就会发生library not found的错误：{% post_link C/'解决找不到RUNPATH下的库的问题' %}

### 存在的问题

#### gcc internal error

Debian 11上的gcc版本为`10.2.1 20210110`，太老了。如果出现了internal error的话，可以用`nix`安装新版本的`gcc10`：

```shell
nix-env -iA nixpkgs.gcc10
```

`nix`包管理器教程：{% post_link Distro/'使用国内源安装和使用Nix包管理器' %}

## 配置环境变量

把编译安装的目录的绝对路径存入`CACHELIB_HOME`里，然后在`~/.profile`里加入如下内容来将其头文件和库暴露出去：

```shell
export CPLUS_INCLUDE_PATH=$CACHELIB_HOME/include:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=$CACHELIB_HOME/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=$CACHELIB_HOME/lib:$LD_LIBRARY_PATH
export CMAKE_PREFIX_PATH=$CACHELIB_HOME/lib/cmake:$CMAKE_PREFIX_PATH
```

然后`source ~/.profile`

## 使用

官方文档：<https://cachelib.org/docs/>

### CMake

官方文档里似乎没写。

```cmake
find_package(cachelib REQUIRED)

target_link_libraries(${PROJECT_NAME}
	PRIVATE
		cachelib
)
```

```shell
# Additional "FindXXX.cmake" files are here (e.g. FindSodium.cmake)
CLCMAKE="$workspace/CacheLib/cachelib/cmake"
CMAKE_PARAMS="-DCMAKE_MODULE_PATH='$CLCMAKE'"

mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo $CMAKE_PARAMS
make
cd ..
```

### 头文件

```cpp
#include <cachelib/allocator/CacheAllocator.h>
```

### `Hybrid Cache`

```cpp
  facebook::cachelib::LruAllocator::Config lruConfig;
  facebook::cachelib::LruAllocator::NvmCacheConfig nvmConfig;
  nvmConfig.navyConfig.setBlockSize(4096);
  nvmConfig.navyConfig.setSimpleFile(
      options.db_paths[0].path + "/cachelib",
      cachelib_size,
      true /*truncateFile*/);
  nvmConfig.navyConfig.blockCache().setRegionSize(16 * 1024 * 1024);
  lruConfig.enableNvmCache(nvmConfig);
  lruConfig.setAccessConfig({/*bucketsPower*/ 25, /*locksPower*/ 10})
      .validate();
  facebook::cachelib::LruAllocator cache(lruConfig);
  auto poolId =
    cache.addPool("default_pool", cache.getCacheMemoryStats().ramCacheSize);
```

`bucketsPower`默认是10，也就是默认1024个bucket，`locksPower`默认是5，也就是32个lock，都太小了，一定要手动调成更大的值。`bucketsPower`取值教程：<https://cachelib.org/docs/Cache_Library_User_Guides/Configure_HashTable#choosing-a-good-value>

### 常用方法

`allocate(poolId, key, value_size)`: 返回`WriteHandle`

`WriteHandle::getMemory`, `WriteHandle::getSize`: value的内存起始地址和大小。可以用`memcpy`之类的往这块内存里面写东西。但好像不能更改大小。

`insertOrReplace(WriteHandle)`

`find(key)`: 返回`ReadHandle`

`findToWrite`: 返回`WriteHandle`

检查`ReadHandle`或者`WriteHandle`是否有效：`if (handle) {`

`ReadHandle::getMemory`, `ReadHandle::getSize`: value的内存起始地址和大小。只读。

`remove(key)`
