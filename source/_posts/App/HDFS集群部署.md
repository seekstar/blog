---
title: HDFS集群部署
date: 2022-06-07 20:16:14
tags:
---

这里假设name node的host name为`hdfs-name`，需要配置三个data node，host name分别为: `hdfs-data-0`, `hdfs-data-1`, `hdfs-data-2`。

## 下载

<https://dlcdn.apache.org/hadoop/common/>

这里假设解压到了`~/software/hadoop`。所以

```shell
export HADOOP_HOME=~/software/hadoop
```

## 依赖

hadoop的运行需要JRE：

```shell
# Debian 11
sudo apt install default-jre
```

## hadoop 配置文件

这些配置文件要放到所有name node和data node的`$HADOOP_HOME/etc/hadoop`：

### hadoop-env.sh

设置一些环境变量，比如`export JAVA_HOME=/usr/lib/jvm/default-java`

### core-site.xml

设置HDFS的交互端口（通常为9000）。我的：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
	<property>
		<name>fs.defaultFS</name>
		<value>hdfs://hdfs-name:9000</value>
	</property>
</configuration>
```

### workers

放data node的名字。后续访问data node都是通过这些名字访问的。本例：

```text
hdfs-data-0
hdfs-data-1
hdfs-data-2
```

### hdfs-site.xml

可以设置默认replica个数，以及name node和data node的数据库文件存放的目录。我的：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
	<property>
		<name>dfs.replication</name>
		<value>3</value>
	</property>
	<property>
		<name>dfs.namenode.name.dir</name>
		<value>/home/searchstar/hdfs-name</value>
	</property>
	<property>
		<name>dfs.datanode.data.dir</name>
		<value>/home/searchstar/hdfs-data</value>
	</property>
</configuration>
```

## /etc/hosts

因为name node和data node依赖host name来通信，所以需要在`/etc/hosts`里添加对host name的解析。

### Name node

Name node需要能够解析它自己（不知道为什么），而且需要把`/etc/hosts`里对自己的解析：

```text
127.0.1.1      hdfs-name
```

改成

```text
192.168.122.102 hdfs-name
```

因为可能是9000端口有一些奇怪的限制：

```text
$ telnet localhost 9000
Trying ::1...
Trying 127.0.0.1...
telnet: Unable to connect to remote host: Connection refused

$ telnet 192.168.122.102 9000
Trying 192.168.122.102...
Connected to 192.168.122.102.
Escape character is '^]'.
```

参考：
<https://stackoverflow.com/questions/18322102/hadoop-connection-refused-on-port-9000>

<https://askubuntu.com/questions/352868/i-cant-connect-to-hadoop-port-9000>

此外，还需要添加对data nodes的host name的解析：

```text
192.168.122.103 hdfs-data-0
192.168.122.105 hdfs-data-1
192.168.122.106 hdfs-data-2
```

### Data node

一定要解析name node的host name。但是保险起见，我把所有node的主机名都解析了：

```text
192.168.122.102 hdfs-name
192.168.122.103 hdfs-data-0
192.168.122.105 hdfs-data-1
192.168.122.106 hdfs-data-2
```

## SSH

需要配置公钥登录，使得name node能够免密码ssh到每个data node。（不知道是否需要能够免密码登录到自己）

## 启动集群

在name node上：

```shell
$HADOOP_HOME/sbin/start-dfs.sh
```

会自动启动data node。

Name node的默认Web UI端口为9870。

## 其他

### 更改权限

如果没有写权限会报错：

```text
mkdir: Permission denied: user=xinyu, access=WRITE, inode="/":searchstar:supergroup:drwxr-xr-x
```

可以用chmod解决：

```shell
bin/hdfs dfs -chmod 777 /
```

参考：<https://my.oschina.net/u/3197158/blog/1492629>

### 修改已有数据的replica数量

`hdfs-site.xml`里设置的是默认的replica数量，仅对新增数据有效。如果要修改老的数据的replica数量，比如修改为3，可以这样：

```shell
# 单个文件
$HADOOP_HOME/bin/hdfs dfs -setrep -w 3 /myfile
# 整个目录
$HADOOP_HOME/bin/hdfs dfs -setrep -w 3 /mydir
```

来源：<https://community.cloudera.com/t5/Support-Questions/Replication-factor-not-changed-in-HDFS-from-hdfs-site-xml/td-p/217100>

## 注意事项

不能通过复制已有data node的磁盘来新增data node，否则会出现ID冲突：

```text
Data node DatanodeRegistration(192.168.122.105:9866, datanodeUuid=d41eb640-253f-486c-94aa-bff5680fb18f, infoP
ort=9864, infoSecurePort=0, ipcPort=9867, storageInfo=lv=-57;cid=CID-0762fc1d-0181-42d5-b385-c3fdc56910
72;nsid=286492513;c=1652290033280) is attempting to report storage ID d41eb640-253f-486c-94aa-bff5680fb
18f. Node 192.168.122.103:9866 is expected to serve this storage.
```

## 官方文档

<https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html>

<https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html>

<https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html>

<https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HdfsUserGuide.html>
