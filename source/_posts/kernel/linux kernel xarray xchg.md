---
title: linux kernel xarray xchg
date: 2021-02-02 00:53:56
---

内核里的xarray里有`xa_cmpxchg`，但是我想要无条件交换的`xa_xchg`，找了一个多小时没找到，结果发现`xa_store`会返回旧值，相当于无条件交换。

还是太嫩了。
