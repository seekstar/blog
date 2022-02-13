---
title: 用YCSB测试RocksDB性能
date: 2022-01-22 23:39:50
tags: RocksDB
---

## 基础用法

### 编译

```shell
git clone https://github.com/brianfrankcooper/YCSB.git
```

```shell
# 提供mvn命令
sudo apt install -y maven
```

```shell
mvn -pl site.ycsb:rocksdb-binding -am clean package -T 线程数
```

有些老的教程里是用的```com.yahoo.ycsb```，最新版本的YCSB已经换成了```site.ycsb```。

### 负载测试

YCSB在```workloads```目录下有一些预定义的workload，这里以workloada为例：

```shell
bin/ycsb.sh load rocksdb -s -P workloads/workloada -p rocksdb.dir=/tmp/rocksdb_test/
```

但是直接运行这个会报错，因为默认的```rocksdb/pom.xml```里少了依赖，要把```core/pom.xml```里的这两个依赖加到```rocksdb/pom.xml```里的```dependencies```里：

- htrace

```
    <dependency>
      <groupId>org.apache.htrace</groupId>
      <artifactId>htrace-core4</artifactId>
      <version>4.1.0-incubating</version>
    </dependency>
```

解决这个错误：

```
Exception in thread "main" java.lang.NoClassDefFoundError: org/apache/htrace/core/Tracer$Builder
```

- HdrHistogram

```
    <dependency>
      <groupId>org.hdrhistogram</groupId>
      <artifactId>HdrHistogram</artifactId>
      <version>2.1.4</version>
    </dependency>
```

解决这个错误：

```
Exception in thread "Thread-2" java.lang.NoClassDefFoundError: org/HdrHistogram/EncodableHistogram
```

添加完这两个依赖之后再重新构建包：

```shell
mvn -pl site.ycsb:rocksdb-binding -am clean package -T 线程数
```

再跑```workloada```：

```shell
rm -r /tmp/rocksdb_test/
bin/ycsb.sh load rocksdb -s -P workloads/workloada -p rocksdb.dir=/tmp/rocksdb_test/
```

### 切换rocksdb版本

YCSB项目根目录下的pom.xml里有一行：

```
<rocksdb.version>版本号</rocksdb.version>
```

修改版本号就会自动下载对应版本的rocksdb来测试性能了。

## 测试自己改的rocksdb的性能

### 安装依赖

#### JDK

```shell
sudo apt install -y default-jdk
export JAVA_HOME=/usr/lib/jvm/default-java
```

参考：<https://seekstar.github.io/2022/01/21/java-home-is-not-set/>

#### cmake

```shell
sudo apt install -y cmake
```

#### 跨平台相关包（未验证）

如果不安装这些依赖，就要改```Makefile```来取消跨平台，教程：[rocksdb在YCSB中的运行教程](https://blog.csdn.net/a993096281/article/details/87864340)。注意，用```#```注释掉可能不太行，最好直接删掉。

简单起见，这里就装一下这些依赖。

```shell
sudo apt install -y vagrant
```

再安装virtualbox，debian用户可以看这里：<https://wiki.debian.org/VirtualBox>

但是我安装virtualbox的时候报错了：

```
The character device /dev/vboxdrv does not exist
```

可能要把secure boot关掉才行：<https://stackoverflow.com/questions/60350358/how-do-i-resolve-the-character-device-dev-vboxdrv-does-not-exist-error-in-ubu>

### 构建并使用rocksdb java包

因为YCSB是用java写的，所以要构建rocksdb的java包来测试。

```shell
make rocksdbjavastaticrelease
```

编译出来的文件在```java/target/rocksdbjni-6.27.3.jar```。

把这个文件复制到YCSB的```rocksdb/target/dependency/```下面，然后更改```rocksdb/pom.xml```，找到```rocksdbjni```的部分，把它的```version```从默认的

```
<version>${rocksdb.version}</version>
```

改成

```
<version>6.27.3</version>
```

这样就会使用我们手动编译出来的rocksdb版本了。然后重新构建binding：

```shell
mvn -pl site.ycsb:rocksdb-binding -am clean package
```

运行测试：

```shell
bin/ycsb.sh load rocksdb -s -P workloads/workloada -p rocksdb.dir=/tmp/rocksdb_test/
```

从输出可以看到已经用上了```rocksdbjni-6.27.3.jar```：

```
/usr/lib/jvm/default-java/bin/java  -classpath /home/searchstar/git/YCSB/conf:/home/searchstar/git/YCSB/core/target/core-0.18.0-SNAPSHOT.jar:/home/searchstar/git/YCSB/rocksdb/target/rocksdb-binding-0.18.0-SNAPSHOT.jar:/home/searchstar/git/YCSB/rocksdb/target/dependency/HdrHistogram-2.1.4.jar:/home/searchstar/git/YCSB/rocksdb/target/dependency/htrace-core4-4.1.0-incubating.jar:/home/searchstar/git/YCSB/rocksdb/target/dependency/jcip-annotations-1.0.jar:/home/searchstar/git/YCSB/rocksdb/target/dependency/rocksdbjni-6.27.3.jar:/home/searchstar/git/YCSB/rocksdb/target/dependency/slf4j-api-1.7.25.jar:/home/searchstar/git/YCSB/rocksdb/target/dependency/slf4j-simple-1.7.25.jar site.ycsb.Client -load -db site.ycsb.db.rocksdb.RocksDBClient -s -P workloads/workloada -p rocksdb.dir=/tmp/rocksdb_test/
```

### gitignore下载的依赖

rocksdb编译了之后会下载很多.tar.gz，并且解压到项目目录了。.tar.gz文件可以直接删掉。在这些依赖的目录里执行

```shell
echo \* > .gitignore
```

来让git忽略这些依赖。

## 参考文献

[rocksdb在YCSB中的运行教程](https://blog.csdn.net/a993096281/article/details/87864340)
