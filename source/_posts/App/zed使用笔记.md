---
title: zed使用笔记
date: 2024-07-24 12:43:54
tags:
---

## 安装

### 官方脚本

```shell
# stable版本。升级也是这个命令
curl -f https://zed.dev/install.sh | sh
# preview版本。升级也是这个命令
curl -f https://zed.dev/install.sh | ZED_CHANNEL=preview sh
```

安装的zed的命令名字就叫`zed`。

### flatpak

```shell
flatpak install dev.zed.Zed
```

### `pacman`

```shell
# ArchLinux。命令名字叫zeditor
sudo pacman -S zed
```

### Nix

```shell
# 目前只有unstable channel有
nix-channel --update
nix-env -iA nixpkgs.zed-editor
```

会调用cargo编译一堆东西

## `VulkanError`

输入命令`zed`或者`zeditor`就可以打开zed编辑器。如果报错`VulkanError(ERROR_INCOMPATIBLE_DRIVER)`，则需要根据自己的硬件配置安装相应的`vulkan`包。

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
2. 删除以前没下载完的文件：`rm ~/.zed_server/*.gz`
3. 手动下载server：

```shell
version=0.175.6
channel=stable
cd ~/.zed_server/
wget https://github.com/zed-industries/zed/releases/download/v$version/zed-remote-server-linux-x86_64.gz
gzip -d zed-remote-server-linux-x86_64.gz
mv zed-remote-server-linux-x86_64 zed-remote-server-$channel-$version
chmod +x zed-remote-server-$channel-$version
```

然后再在zed里尝试连接到服务器就好了。

## 常用快捷键

完整的快捷键列表：<https://zed.dev/docs/key-bindings>。注意，这里面`⌘`对应`ctrl`而不是Super/Win键。

完整的默认快捷键配置：<https://github.com/zed-industries/zed/blob/main/assets/keymaps/default-macos.json>

| Command | Target | Default shortcut |
| ---- | ---- | ---- |
| `Toggle focus` | `Terminal Panel` | `` ctrl+` `` |
| `Toggle filters` | `Project Search`，在项目中全局搜索 | `ctrl+shift+f` |

`Newline below`默认的快捷键是`⌘ + Enter`，在Linux上本来对应`ctrl+Enter`。但这个快捷键被`assistant::InlineAssist`占用了。所以需要在`~/.config/zed/keymap.json`里手动指定一下：

```json
[
  {
    "context": "Editor",
    "bindings": {
      "ctrl-enter": "editor::NewlineBelow"
    }
  }
]
```

## `settings.json`

官方文档：<https://zed.dev/docs/configuring-zed>

### 常用配置项

- [soft_wrap](https://zed.dev/docs/configuring-zed#soft-wrap)

### 按语言配置

例子：

```json
{
  ...
  "languages": {
    "Markdown": {
      "tab_size": 4,
      "hard_tabs": true,
      "soft_wrap": "editor_width"
    }
  }
  ...
}
```

支持的语言列表：<https://zed.dev/docs/languages>

## 目前的问题

- remote上只能通过`Open Folder`来打开工程，不能像vscode一样在terminal里`zed folder`来打开。

- 只有git blame，没有vscode那样的git功能。可以先用lazygit凑活一下。

- 不能隐藏terminal panel

## 已经解决的问题

- 不能preview markdown

- formatter不能在remote用: <https://github.com/zed-industries/zed/issues/13527>
