---
title: "*** WARNING : deprecated key derivation used. Using -iter or -pbkdf2 would be better."
date: 2020-08-22 16:01:01
tags:
---

参考：<https://unix.stackexchange.com/questions/507131/openssl-1-1-1b-warning-using-iter-or-pbkdf2-would-be-better-while-decrypting>

加上```-pbkdf2```即可。
```
openssl aes-256-cbc -salt -pbkdf2 -in name -out name.aes
```
```
openssl aes-256-cbc -d -salt -pbkdf2 -in name.aes -out name
```
但是要注意没有用```-pbkdf2```加密的文件不能用```-pbkdf2```选项解密。
