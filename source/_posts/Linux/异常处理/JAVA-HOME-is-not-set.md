---
title: JAVA_HOME is not set
date: 2022-01-21 22:19:55
tags:
---

安装jdk，然后

```shell
ls /usr/lib/jvm/
```

我的：

```
default-java  java-1.11.0-openjdk-amd64  java-11-openjdk-amd64
```

挑一个合适的版本设置成```JAVA_HOME```即可。

其中```default-java```和```java-1.11.0-openjdk-amd64```都是指向```java-11-openjdk-amd64```的软链接。所以可以直接将```JAVA_HOME```设置成```/usr/lib/jvm/default-java```：

```shell
export JAVA_HOME=/usr/lib/jvm/default-java
```

来源：<https://www.cnblogs.com/guxiaobei/p/8556586.html>
