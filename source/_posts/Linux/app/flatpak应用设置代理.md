---
title: flatpak应用设置代理
date: 2022-01-06 12:31:56
tags:
---

```shell
flatpak run --command=sh 包名
```

会进入沙箱环境的shell。然后在这个shell里设置系统代理：

```shell
# 系统代理模式设置为手动
gsettings set org.gnome.system.proxy mode manual
# 设置 HTTP 代理
gsettings set org.gnome.system.proxy.http host localhost
gsettings set org.gnome.system.proxy.http port 端口号
# 设置 HTTPS 代理
gsettings set org.gnome.system.proxy.https host localhost
gsettings set org.gnome.system.proxy.https port 端口号
# 设置 Socks 代理
gsettings set org.gnome.system.proxy.socks host localhost
gsettings set org.gnome.system.proxy.socks port 端口号
```

亲测对Element(im.riot.Riot)有效。

来源：

<https://github.com/flathub/com.mattermost.Desktop/issues/23>

<https://blog.junjie.pro/posts/2021/05/set-up-proxy-for-flatpak-apps/>
