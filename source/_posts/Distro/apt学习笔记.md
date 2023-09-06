---
title: apt学习笔记
date: 2023-09-05 14:46:43
tags:
---

查看某个包的依赖，以及哪些包依赖这个包：

```shell
apt-cache showpkg package_name
```

树形的依赖图：

```shell
sudo apt install apt-rdepends
# 这个包依赖哪些包
apt-rdepends package_name
# 哪些包依赖这个包
apt-rdepends -r package_name
```

其他选项：

`--state-follow=Installed --state-show=Installed`: 只查看已安装的包。例如：查看哪些已安装的包依赖这个包：`apt-rdepends -r package_name --state-follow=Installed --state-show=Installed`

## 参考文献

[如何查询摸个版本包的依赖关系和被依赖关系](https://blog.csdn.net/weixin_56286468/article/details/131572964)
