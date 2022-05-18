---
title: h5bench
date: 2022-05-18 17:22:55
tags:
---

官方文档：<https://h5bench.readthedocs.io/en/latest/buildinstructions.html>

## 编译安装 HDFS

截至发文，这里最新版本只有1.12.1：<https://www.hdfgroup.org/downloads/hdf5/>

要下载1.13，需要到这里下载：<https://portal.hdfgroup.org/display/support/Downloads>

要按照这里面的提示安装启用了parallel的HDF5：`release_docs/INSTALL_parallel`

如果没有启用parallel的话，之后编译h5bench的时候会报`MPI_COMM_WORLD undeclared`的错误。

其他选项是根据vol-async的文档加上的。

```shell
./configure --prefix=$(pwd)/install --enable-parallel --enable-threadsafe --enable-unsupported
make -j$(nproc)
make install
echo "export HDF5_HOME=$(pwd)/install" >> ~/.bashrc
source ~/.bashrc
```

## 编译安装 argobots

<https://github.com/pmodels/argobots>

```shell
./configure --prefix=$(pwd)/install
make -j$(nproc)
make install
```

## 编译安装 VOL (Virtual Object Layer)

所有可用的VOL: <https://portal.hdfgroup.org/display/support/Registered+VOL+Connectors>

这里用vol-async: <https://github.com/hpc-io/vol-async>

```shell
cd src
cp Makefile.summit Makefile
```

然后把Makefile里的`HDF5_DIR`和`ABT_DIR`分别改成HDFS和argobots的安装目录。

然后就可以编译了：

```shell
make -j$(nproc)
```

注意，vol-async v1.1与 HDF5 v1.12.1不兼容。

## 编译安装 h5bench

```shell
sudo apt install libpnetcdf-dev
```

```shell
mkdir build
cd build
cmake .. -DH5BENCH_ALL=ON
make -j$(nproc)
echo "export PATH=$(pwd):\$PATH" >> ~/.bashrc
source ~/.bashrc
```

不需要跑`sudo make install`。而且跑了之后，安装在系统目录下的`h5bench`的权限位是700，所以普通用户没法执行。

注意，一定要把build目录加入到`PATH`里，不然后面跑实验的时候会报这个错：

```text
execvp error on file h5bench_write (No such file or directory)
```

## 运行 h5bench

官方文档：<https://h5bench.readthedocs.io/en/latest/running.html>

配置文件的一些坑：

不能有多余的逗号，不然log里会报错：`CRITICAL - Unable to find and parse the input configuration file`。

`benchmarks`下面的每个`benchmark`里的`configuration`都要加上`"MODE": "SYNC"`或者`"MODE": "ASYNC"`，并且把`"ASYNC_MODE": "NON",`去掉。不然会报这个错：`h5bench - ERROR - Unable to run the benchmark: 'MODE'`。

`mpi`的`configuration`要去掉`--oversubscribe`。

我的配置文件：

```json
{
    "mpi": {
        "command": "mpirun",
        "ranks": "4",
        "configuration": "-np 8"
    },
    "vol": {
        "library": "/home/searchstar/git/others/vol-async/src:/home/searchstar/Downloads/argobots-1.1/install/lib:/home/searchstar/Downloads/hdf5-1.13.1/install/lib:",
        "path": "/home/searchstar/git/others/vol-async/src",
        "connector": "async under_vol=0;under_info={}"
    },
    "file-system": {
        "lustre": {
            "stripe-size": "1M",
            "stripe-count": "4"
        }
    },
    "directory": "test-dir",
    "benchmarks": [
        {
            "benchmark": "write",
            "file": "test.h5",
            "configuration": {
                "MEM_PATTERN": "CONTIG",
                "FILE_PATTERN": "CONTIG",
                "NUM_PARTICLES": "16 M",
                "TIMESTEPS": "5",
                "DELAYED_CLOSE_TIMESTEPS": "2",
                "COLLECTIVE_DATA": "NO",
                "COLLECTIVE_METADATA": "NO",
                "EMULATED_COMPUTE_TIME_PER_TIMESTEP": "1 s",
                "NUM_DIMS": "1",
                "DIM_1": "10000",
                "DIM_2": "1",
                "DIM_3": "1",
                "CSV_FILE": "output.csv",
                "MODE": "SYNC"
            }
        }
    ]
}
```

## 参考

<https://support.hdfgroup.org/HDF5/PHDF5/>
