---
title: sha校验文件使用方法
date: 2021-04-12 15:11:57
---

把`FileName`和`FileName.sha512`都下载下来之后，在下载目录中执行
```shell
shasum -c FileName.sha512
```
如果校验通过，就会显示
```
FileName: OK
```
