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
./contrib/build.sh -j -T
```

编译的结果在`opt`里。

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
