---
title: SpanDB运行YCSB测试
date: 2022-01-23 22:00:50
tags: RocksDB
---

官方教程：<https://github.com/SpanDB/SpanDB>

但是官方教程有一些坑。

## 安装SPDK

{% post_link Linux/'Debian-11-安装SPDK' %}

## （可选）把memlock的限制解除

```shell
sudo bash -c "ulimit -Hl unlimited"
ulimit -Sl unlimited
```

## 申请huge page

```shell
# 4GB
sudo HUGEMEM=4096 scripts/setup.sh
```

这个时候可能会提示：

```
Current user memlock limit: 3967 MB

This is the maximum amount of memory you will be
able to use with DPDK and VFIO if run as current user.
To change this, please adjust limits.conf memlock limit for current user.
```

但是查看```/proc/meminfo```的话，又能看到huge page已经分配好了：

```
HugePages_Total:   2048
HugePages_Free:    2048
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
```

SpanDB的TopFS的cache是从这里申请的。如果后面出现了内存分配失败，说明这里没有申请够，需要把数值改大，或者减小TopFS的cache大小。

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

数据写入完成之后会sleep两个3分钟，可能是为了等待后台任务完成，然后打印一些信息之后才会退出，要耐心等待。

注意，load模式不支持SpanDB，测试SpanDB的时候用的db_bak跟RocksDB是一样的。

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

SpanDB默认分配了90GB的SPDK缓存，如果前面huge page没有申请够，会分配失败：

```
SPDK memory allocation starts (90.00 GB)
...0.0%
already allocated 3.38 GB
/home/searchstar/git/others/SpanDB/env/io_spdk.h:111: SPDK allocate memory failed
```

这时要么多申请一些huge page，要么减少TopFS使用的cache，即将```ycsb/src/test.cc```中的```main```函数里的

```C
options.topfs_cache_size = 90;
```

改成更小的值，然后重新```make```，再跑就好了。

## 相关

{% post_link Linux/SPDK回收hugemem %}

## 参考文献

<https://github.com/SpanDB/SpanDB>

<https://wiki.debian.org/Hugepages>

<https://askubuntu.com/questions/654820/how-to-find-pci-address-of-an-ethernet-interface>
