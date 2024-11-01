---
title: zed使用笔记
date: 2024-07-24 12:43:54
tags:
---

## 安装

```shell
# stable版本。升级也是这个命令
curl -f https://zed.dev/install.sh | sh
# preview版本。升级也是这个命令
curl -f https://zed.dev/install.sh | ZED_CHANNEL=preview sh
```

官方脚本安装的zed的命令名字就叫`zed`。

也可以用包管理器安装，不过好像只能安装stable版本：

```shell
# ArchLinux。命令名字叫zeditor
sudo pacman -S zed
# Nix。目前只有unstable channel有
nix-env -iA nixpkgs.zed-editor
```

然后输入命令`zed`或者`zeditor`就可以打开zed编辑器。如果报错`VulkanError(ERROR_INCOMPATIBLE_DRIVER)`，则需要根据自己的硬件配置安装相应的`vulkan`包。

例如我用的是Intel集显，那么就安装`vulkan-intel`:

```shell
sudo pacman -S vulkan-intel
```

参考：<https://github.com/zed-industries/zed/issues/14436#issuecomment-2227309862>

## 连接到服务器

官方教程：<https://zed.dev/docs/remote-development>

`ctrl+shift+p` -> `projects: open remote` -> `Connect New Server`

如果服务器端的`zed`下载卡住的话，可以新开一个终端ssh到服务器，然后在上面手动把服务端下载下来：

1. `ps -ef | grep zed`，把所有之前`zed`自动创建的下载进程杀掉。
2. 删除以前没下载完的文件：`rm ~/.zed_server/*`
3. 手动下载server。首先在github上找到要下载的版本：<https://github.com/zed-industries/zed/releases>，然后在服务器上手动下载：

```shell
version=v0.159.7
channel=stable
cd ~/.zed_server/
wget https://github.com/zed-industries/zed/releases/download/$version/zed-remote-server-linux-x86_64.gz
gzip -d zed-remote-server-linux-x86_64.gz
mv zed-remote-server-linux-x86_64 zed-remote-server-$channel-linux-x86_64
chmod +x zed-remote-server-stable-linux-x86_64
```

然后再在zed里尝试连接到服务器就好了。

## 目前的问题

- remote上只能通过`Open Folder`来打开工程，不能像vscode一样在terminal里`zed folder`来打开。

- 只有git blame，没有vscode那样的git功能。

- formatter似乎不能在remote用: <https://github.com/zed-industries/zed/issues/13527>

## 已经解决的问题

- 不能preview markdown
