---
title: 支付宝 RSA2密钥长度不正确
date: 2020-06-30 21:25:59
tags:
---

要生成长度为2048的密钥。。。

```shell
genrsa -out app_private_key.pem   2048
rsa -in app_private_key.pem -pubout -out app_public_key.pem
```
