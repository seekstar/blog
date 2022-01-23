---
title: SpanDB运行YCSB测试
date: 2022-01-23 22:00:50
tags: RocksDB
---

官方教程：<https://github.com/SpanDB/SpanDB>

但是官方教程有一些坑。

## 安装SPDK

{% post_link Linux/'Debian-11-安装SPDK' %}

## 申请huge page

```shell
# 4GB
sudo HUGEMEM=4096 scripts/setup.sh
```

官方文档里说这个一定要大于SpanDB的cache的大小，但是没说哪里看SpanDB的cache大小。。

## 安装依赖

Debian 11：

```shell
sudo apt-get install libgflags-dev
sudo apt-get install libsnappy-dev
sudo apt-get install zlib1g-dev
sudo apt-get install libbz2-dev
sudo apt-get install liblz4-dev
sudo apt-get install libzstd-dev
sudo apt-get install libtbb-dev
```

我怀疑其实并不需要这么多压缩算法。但是稳妥起见还是按照官方文档上的全装上吧。

## 编译SpanDB

```shell
git clone https://github.com/SpanDB/SpanDB.git
cd SpanDB
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX:PATH=. -DWITH_TESTS=OFF -DCMAKE_BUILD_TYPE=Release -DUSE_RTTI=true -DFAIL_ON_WARNINGS=false
make -j$(nproc)
# make install
```

我这里make的时候会报错：

```
db_stress.cc:(.text.startup+0x1): undefined reference to `rocksdb::db_stress_tool(int, char**)'
```

但是build文件夹下面```librocksdb```的静态库和动态库都编译好了，所以这条编译报错也许可以不用管？

## 编译SpanDB目录下面的YCSB测试程序

```shell
cd SpanDB/ycsb
```

这下面的```CMakeLists.txt```是错的，要把

```
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/../build/include)
```

改成

```
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/../include)
```

把

```
LINK_DIRECTORIES(${PROJECT_SOURCE_DIR}/../build/lib64)
```

改成

```
LINK_DIRECTORIES(${PROJECT_SOURCE_DIR}/../build)
```

然后再编译：

```shell
mkdir build
cd build
cmake ../
make
```

## 运行YCSB测试

使用编译出来的```test```文件来测试，其参数：

```
usage: <workload_file> <client_num> <data_dir> <log_dir> <is_load> <dbname> <db_bak>
```

在```ycsb/workloads```下面有一些自带的workload。

### 生成DB

```shell
./test <workload_file> 40 <data_dir> <log_dir> 1 rocksdb <db_bak>
```

这个时候最后一个参数```db_bak```会被忽略，生成的DB在```data_dir```里。需要手动把```data_dir```移动到```db_bak```。

### 测试RocksDB

```shell
# 临时起效
ulimit -n 100000
./test <workload_file> 40 <data_dir> <log_dir> 0 rocksdb <db_bak>
```

这一步会先把```data_path```给清空，然后把```db_bak```里的内容复制到```data_path```里，然后再跑workload。

官方文档里这一步没有```ulimit -n 100000```，但是```workloada.spec```生成的DB里有1608个文件，而默认最多能同时打开1024个file descriptor：

```
$ ulimit -n
1024
```

### 测试SpanDB

```shell
sudo -s
# 临时生效
ulimit -n 100000
./test <workload_file> 8 <data_dir> $PCIE_ADDR 0 spandb <db_bak>
```

其中PCIe地址可以通过```sudo lspci```查找，我的是：

```
01:00.0 Non-Volatile memory controller: Samsung Electronics Co Ltd NVMe SSD Controller PM9A1/980PRO
```

其中的```01:00.0```就是这个SSD的PCIe地址。

## 参考文献

<https://github.com/SpanDB/SpanDB>

<https://askubuntu.com/questions/654820/how-to-find-pci-address-of-an-ethernet-interface>
