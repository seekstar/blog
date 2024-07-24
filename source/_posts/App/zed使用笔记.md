---
title: zed使用笔记
date: 2024-07-24 12:43:54
tags:
---

## 安装

```shell
curl -f https://zed.dev/install.sh | sh
```

也可以用包管理器安装：

```shell
# ArchLinux
sudo pacman -S zed
# Nix
nix-env -iA nixos.zed-editor
```

然后输入命令`zed`就可以打开zed编辑器。如果报错`VulkanError(ERROR_INCOMPATIBLE_DRIVER)`，则需要根据自己的硬件配置安装相应的`vulkan`包。

例如我用的是Intel集显，那么就安装`vulkan-intel`:

```shell
sudo pacman -S vulkan-intel
```

参考：<https://github.com/zed-industries/zed/issues/14436#issuecomment-2227309862>

## 连接到服务器

官方教程：<https://zed.dev/docs/remote-development>

目前只有preview版本可以。先安装preview版本：

```shell
curl -f https://zed.dev/install.sh | ZED_CHANNEL=preview sh
```

然后`ctrl+shift+p` -> `projects: open remote` -> `New Server`

如果服务器端的`zed`下载卡住的话，可以新开一个终端ssh到服务器，然后在上面手动把服务端下载下来：

```shell
curl https://zed.dev/install.sh | bash
```

## 目前的问题

- 只有git blame，没有vscode那样的git功能。

- 不能preview markdown

- formatter似乎不能在remote用: <https://github.com/zed-industries/zed/issues/13527>
