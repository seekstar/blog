---
title: USTC mirror将CentOS 8升级为stream
date: 2022-03-06 10:25:50
tags:
---

貌似将`/etc/yum.repo.d/`里的

```text
baseurl=http://mirrors.ustc.edu.cn/centos/$releasever/xxxx/$basearch/os/
```

都写成

```text
baseurl=http://mirrors.ustc.edu.cn/centos/$releasever-stream/xxxx/$basearch/os/
```

也就是在`$releasever`后面加上`-stream`，然后

```shell
sudo yum makecache
sudo yum update --allowerasing
```

就可以了。
