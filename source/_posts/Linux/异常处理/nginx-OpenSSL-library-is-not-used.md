---
title: nginx OpenSSL library is not used
date: 2022-01-21 22:23:01
tags:
---

即使装上了```openssl-devel```，如果```./configure```时没有带上```--with-http_ssl_module```，还是会显示```OpenSSL library is not used```，这样的话就不能listen ssl了，否则会报错：

```
the "ssl" parameter requires ngx_http_ssl_module
```

所以解决方法是```./configure```的时候加上```--with-http_ssl_module```：

```shell
./configure --with-http_ssl_module
```

然后这一行就变成了：

```
+ using system OpenSSL library
```

## 其他常用模块

### ngx_http_v2_module

```
the "http2" parameter requires ngx_http_v2_module
```

### stream

```./configure```时如果不带上```-with-stream```的话，用stream的时候会报错：

```
unknown directive "stream"
```
