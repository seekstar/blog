---
title: 加速clone linux kernel
date: 2020-03-07 10:26:07
---

gitee.com有一个```码云极速下载```的用户，id是```mirrors```。这个用户维护了很多github的仓库的镜像，其中就有linux kernel：
```shell
git clone git@gitee.com:mirrors/linux.git
```
实测可以跑满带宽。

建议不要用https的方式：
```shell
git clone https://gitee.com/mirrors/linux.git
```
否则可能会报以下错误，且尝试了网上的修复方法，都无效。

- error: RPC failed; curl 56 GnuTLS recv error (-110): The TLS connection was non-properly terminated.

- error: RPC failed; curl 18 transfer closed with outstanding read data remaining
