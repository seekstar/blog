---
title: 解决route53域名transfer之后lightsail DNS zone的record无效的问题
date: 2023-12-31 14:19:44
tags:
---

## 症状

把route 53的域名transfer给另一个账户之后，在新账户给这个域名创建一个lightsail DNS zone，然后把这个域名attach到一个instance的IP上。但是等了很久域名解析仍然失败：

```shell
ping: net1.seekstar1.link: Temporary failure in name resolution
```

## 解决方案

官方创建DNS zone的教程：<https://lightsail.aws.amazon.com/ls/docs/en_us/articles/lightsail-how-to-create-dns-entry#lightail-change-the-name-servers>

>Step 4: Change the name servers at your domain’s current DNS hosting provider

所以原因就是transfer了域名之后，域名的name server仍然是旧账户的，需要改成新账户的name server。只需要在新账户的lightsail DNS zone里找到对应的name servers，然后在route 53里将域名的name server修改成这些name servers即可。再等一段时间（我这里好像也就几分钟）域名解析就成功了。
