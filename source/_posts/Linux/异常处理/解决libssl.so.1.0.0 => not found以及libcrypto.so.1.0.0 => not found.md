---
title: 解决libssl.so.1.0.0 => not found以及libcrypto.so.1.0.0 => not found
date: 2020-03-27 15:52:48
---

现在的apt源中，libssl1.0的版本一般是libssl1.0.2，libcrypto1.0的版本一般是libcrypto1.0.2。但是很多应用要使用libssl.so.1.0.0和libcrypto.so.1.0.0。

试过软链接，但是没用。
所以只好手动下载它们的安装包了。

libssl1.0.0和libcrypto1.0.0只在Debian 8 (代号Jessie)提供，但是Debian 8从2020 6月开始就不受支持了：<https://www.debian.org/releases/jessie/>

因此这个页面已经无了：<https://packages.debian.org/jessie/>

这里的搜索结果也不再可用：<https://packages.debian.org/search?suite=jessie&arch=any&mode=exactfilename&searchon=contents&keywords=libssl.so.1.0.0>

幸运的是，libssl1.0.0和libcrypto1.0.0还可以在这里找到：<https://security.debian.org/debian-security/pool/updates/main/o/openssl/>

只需要在该页面搜索`libcrypto1.0.0`和`libssl1.0.0`即可。

x86_64的64位版本在这：<https://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb>

libssl.so.1.0.0和libcrypto.so.1.0.0都会被安装到/lib/x86_64-linux-gnu/下。

建议使用gdebi安装（会自动安装依赖）
```shell
sudo gdebi libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb
```
