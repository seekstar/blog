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
```

然后`source ~/.profile`

## 使用

在目标项目的cmake里这么写：

```cmake
	PRIVATE
		# 这些是静态链接库，所以是PRIVATE
		cachelib_allocator
		cachelib_navy
		cachelib_common
		cachelib_shm

	PUBLIC
		# 这些是动态链接库，所以是PUBLIC

		# Deps of cachelib_allocator
		numa
		folly
		thriftprotocol

		# Deps of cachelib_navy
		boost_context

		# Deps of cachelib_shm
		rt

		# Deps of folly
		fmt
		double-conversion
		glog

		# Deps of thriftprotocol
		rpcmetadata
```

或者直接link这个library: <https://github.com/seekstar/RocksCachelibWrapper>

然后正常编译即可。
