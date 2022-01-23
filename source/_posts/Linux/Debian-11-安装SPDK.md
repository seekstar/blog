---
title: Debian 11 安装SPDK
date: 2022-01-23 21:06:12
tags:
---

本文主要参考SpanDB的安装教程：<https://github.com/SpanDB/SpanDB>

SPDK全称：Storage Performance Development Kit

这里以SPDK v20.01.2为例。

## 下载SPDK

```shell
git clone https://github.com/spdk/spdk
cd spdk
git checkout v20.01.2
git submodule update --init
```

## 安装依赖

这个部分SpanDB的教程是：

```shell
sudo ./scripts/pkgdep.sh
```

但是Debian 11上没有pep8包，所以手动安装一下其他依赖，pep8不装好像也没事：

```shell
sudo apt-get install -y gcc g++ make libcunit1-dev libaio-dev libssl-dev \
        git astyle lcov clang uuid-dev sg3-utils libiscsi-dev pciutils \
        shellcheck
sudo apt install nasm
sudo apt install dh-autoreconf
sudo apt install libnuma-dev
```

## 编译安装SPDK

```shell
./configure --with-shared
make -j$(nproc)
sudo make install
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:$PWD/dpdk/build/lib/" >> ~/.bashrc
echo "export DPDK_LIB=$PWD/dpdk/build/lib" >> ~/.bashrc
echo "export DPDK_INCLUDE=$PWD/dpdk/build/include" >> ~/.bashrc
source ~/.bashrc 
```
