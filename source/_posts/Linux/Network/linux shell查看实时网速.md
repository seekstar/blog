---
title: linux shell查看实时网速
date: 2021-07-01 11:17:57
---

# jnettop

```shell
sudo apt install jnettop
jnettop
```

# iftop

```shell
sudo dnf install iftop
```

可以看跟哪些IP的流量最多。

# nethogs

```shell
sudo yum install epel-release
sudo yum install nethogs
sudo nethogs
```

参考：<https://www.linuxprobe.com/centos-nethogs.html>
