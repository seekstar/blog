---
title: cargo build找不到openssl库
date: 2021-07-01 16:15:14
---

ubuntu的话安装```libssl-dev```
```shell
sudo apt install libssl-dev
```
如果还是找不到，其实报错信息里有提示安装```pkg-config```可能可以解决问题：
```shell
sudo apt install pkg-config
```
然后再跑```cargo build```就可以了。
