---
title: 非交互从github中下载最新版安装包
date: 2020-10-31 17:26:26
---

这里以drawio-desktop为例。github链接：<https://github.com/jgraph/drawio-desktop>

# 使用github api来获取这个项目最新的release
```shell
curl -s https://api.github.com/repos/jgraph/drawio-desktop/releases/latest
```
输出一个json，描述了可供下载的一些文件的信息。
# 提取出deb包的url所在的行
```shell
curl -s https://api.github.com/repos/jgraph/drawio-desktop/releases/latest | grep "browser_download_url.*deb"
```
输出：
```
      "browser_download_url": "https://github.com/jgraph/drawio-desktop/releases/download/v13.7.9/draw.io-amd64-13.7.9.deb"
```
# 用cut命令把url提取出来
```shell
curl -s https://api.github.com/repos/jgraph/drawio-desktop/releases/latest | grep "browser_download_url.*deb" | cut -d '"' -f 4
```
其中`-d '"'`表示以`"`作为分界符，`-f 4`表示显示第4个域。
输出：
```
https://github.com/jgraph/drawio-desktop/releases/download/v13.7.9/draw.io-amd64-13.7.9.deb
```
# 用wget下载deb包
```shell
curl -s https://api.github.com/repos/jgraph/drawio-desktop/releases/latest | grep "browser_download_url.*deb" | cut -d '"' -f 4 | wget -i -
```
`-i`表示指定url来源，`-`表示url来源为`stdin`。

# 参考文献
<https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8>
