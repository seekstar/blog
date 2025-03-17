---
title: 给flatpak添加国内镜像源
date: 2021-12-30 20:24:23
tags:
---

上交有flathub的镜像源。官方教程：<https://mirror.sjtu.edu.cn/docs/flathub>

如果已经添加了flathub的话，就用remote-modify修改：

```shell
sudo flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub
```

参考：<https://xuyiyang.com.cn/archives/%E7%BB%99flatpak%E6%B7%BB%E5%8A%A0%E5%9B%BD%E5%86%85%E9%95%9C%E5%83%8F%E6%BA%90>

如果没有的话，就用remote-add添加：

```shell
sudo flatpak remote-add flathub https://mirror.sjtu.edu.cn/flathub/flathub.flatpakrepo
```


留意上交镜像的官方教程里有这句话：

```
Flathub 镜像是 flathub.org 的智能缓存。当您请求镜像中的资源时， 如果文件没有被镜像服务器缓存，我们会将您重定向回原站，并在后台进行缓存。
```

也就是说，如果你要安装的软件没有在上交镜像里缓存，那就会重定向到官方的flathub。如果没有代理的话，可能会显示这个：

```
Error: Could not connect: 网络不可达
error: Failed to install com.spotify.Client: Could not connect: 网络不可达
```

遇到这个情况，要么挂代理，要么等一段时间，等上交镜像把这个包缓存下来之后，再尝试。

如果需要换回官方源的话：

```shell
sudo flatpak remote-modify flathub --url=https://flathub.org/repo
```
