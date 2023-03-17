---
title: 使用国内源安装和使用Nix包管理器
date: 2023-02-04 20:18:49
tags:
---

本文介绍如何使用国内源（以清华源为例）在非NixOS操作系统上安装和使用Nix包管理器。

## 安装

```shell
# https://mirrors.tuna.tsinghua.edu.cn/help/nix/
sh <(curl https://mirrors.tuna.tsinghua.edu.cn/nix/latest/install) --daemon --no-channel-add
source /etc/profile
```

`--no-channel-add`: 不添加`nixpkgs-unstable`作为channel。

否则这一步会很慢：

```text
---- sudo execution ------------------------------------------------------------
I am executing:                                                                      

    $ sudo HOME=/root NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt /nix/store/lsr79q5xqd9dv97wn87x12kzax8s8i1s-nix-2.13.2/bin/nix-channel --update nixpkgs

to update the default channel in the default profile
```

然后新开一个终端，这样才可以用

## 添加channel

```shell
# https://mirrors.tuna.tsinghua.edu.cn/help/nix/
sudo bash -c "echo substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org/ >> /etc/nix/nix.conf"
sudo -i nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable nixpkgs
sudo -i nix-channel --update
nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable nixpkgs
nix-channel --update
sudo systemctl restart nix-daemon.service
```

清华镜像是cache。如果命中了cache，就会显示`copying path '/nix/store/xxx' from 'https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store'...`。如果没有命中，就会显示`copying path '/nix/store/xxx' from 'https://cache.nixos.org'...`，也就是从官方源`https://cache.nixos.org`下载。

## 代理

设置代理可以提高未命中cache时从官方源下载的速度。

```shell
sudo systemctl edit nix-daemon.service
```

```ini
[Service]
Environment="http_proxy=http://localhost:端口号"
Environment="https_proxy=http://localhost:端口号"
```

然后重启`nix-daemon`：

```shell
sudo systemctl restart nix-daemon.service
```

或者直接把内容写进`override.conf`：

```shell
sudo bash -c "cat > /etc/systemd/system/nix-daemon.service.d/override.conf" <<EOF
[Service]
Environment="http_proxy=http://localhost:端口号"
Environment="https_proxy=http://localhost:端口号"
EOF
sudo systemctl daemon-reload
sudo systemctl restart nix-daemon.service
```

可惜似乎不能设置per-user proxy: <https://github.com/NixOS/nix/issues/1472>

参考：<https://serverfault.com/questions/413397/how-to-set-environment-variable-in-systemd-service>

## 基础用法

官方文档：<https://nixos.org/manual/nix/stable/command-ref/nix-env.html>

搜索可用包：<https://search.nixos.org/packages>

安装：`nix-env -iA 源.包名`

卸载：`nix-env -e 包名`

一些`nix-env`的选项：

- `-i`: `--install`

- `-A`: `--attr`。表示从根开始解析，更快。

- `-e`: `--uninstall`

- `-q`: `--query`。默认`--installed`，即只查询已安装的包。也可以加上`-a`，即`--availble`，`nix-env -qa`表示打印源的所有包的列表，`nix-env -qa xxx`表示搜索。但是这个好慢，而且还不能模糊搜索，不如在这里搜索：<https://search.nixos.org/packages>

垃圾回收：`nix-collect-garbage -d`。

```text
-d (--delete-old) deletes  all  old  generations of all profiles in /nix/var/nix/profiles by invoking nix-env --delete-generations old on all profiles (of course, this makes rollbacks to previous configurations impossible)
```

## 运行OpenGL程序

在非NixOS中运行需要OpenGL的程序需要wrapper：<https://nixos.wiki/wiki/Nixpkgs_with_OpenGL_on_non-NixOS>

可以用nixGL来运行这些程序：<https://github.com/guibou/nixGL>。安装：

```shell
nix-channel --add https://github.com/guibou/nixGL/archive/main.tar.gz nixgl && nix-channel --update
nix-env -iA nixgl.auto.nixGLDefault   # or replace `nixGLDefault` with your desired wrapper
```

然后`nixGL 命令`即可。比如`seafile-client`:

```shell
nix-env -iA nixpkgs.seafile-client
```

直接运行`seafile-applet`会报错：

```text
qt.glx: qglx_findConfig: Failed to finding matching FBConfig for QSurfaceFormat(version 2.0, options QFlags<QSurfaceFormat::FormatOption>(), depthBufferSize -1, redBufferSize 1, greenBufferSize 1, blueBufferSize 1, alphaBufferSize -1, stencilBufferSize -1, samples -1, swapBehavior QSurfaceFormat::SingleBuffer, swapInterval 1, colorSpace QSurfaceFormat::DefaultColorSpace, profile  QSurfaceFormat::NoProfile)
qt.glx: qglx_findConfig: Failed to finding matching FBConfig for QSurfaceFormat(version 2.0, options QFlags<QSurfaceFormat::FormatOption>(), depthBufferSize -1, redBufferSize 1, greenBufferSize 1, blueBufferSize 1, alphaBufferSize -1, stencilBufferSize -1, samples -1, swapBehavior QSurfaceFormat::SingleBuffer, swapInterval 1, colorSpace QSurfaceFormat::DefaultColorSpace, profile  QSurfaceFormat::NoProfile)
Could not initialize GLX
Aborted
```

用`nixGL seafile-applet`运行就正常。可以创建一个desktop文件`~/.local/share/applications/seafile-client.desktop`:

```text
[Desktop Entry]
Name=Seafile
Comment=Seafile desktop sync client
Exec=nixGL seafile-applet
Icon=seafile
Type=Application
Categories=Network;FileTransfer;
```

然后就可以在启动器里找到`Seafile`了，点击之即可运行。

## 卸载Nix包管理器

安装完之后安装程序给出的提示，没有试过：

```text
Uninstalling nix:
1. Delete the systemd service and socket units                                       

  sudo systemctl stop nix-daemon.socket
  sudo systemctl stop nix-daemon.service
  sudo systemctl disable nix-daemon.socket
  sudo systemctl disable nix-daemon.service
  sudo systemctl daemon-reload
2. Delete the files Nix added to your system:

  sudo rm -rf /etc/nix /nix /root/.nix-profile /root/.nix-defexpr /root/.nix-channels $HOME/.nix-profile $HOME/.nix-defexpr $HOME/.nix-channels
```

## 允许安装闭源软件

根据输出提示，在`~/.config/nixpkgs/config.nix`（如果没有就创建）里设置：

```text
{ allowUnfree = true; }
```

## 安装和使用库

Nix的设计理念是只将应用暴露给用户，而不将库暴露给用户：<https://nixos.wiki/wiki/FAQ#I_installed_a_library_but_my_compiler_is_not_finding_it._Why.3F>。我认为这是为了支持在一个系统中同时安装多个版本的库。

因此如果用Nix包管理器安装了库，比如gtest: `nix-env -iA nixpkgs.gtest`，编译器是找不到`gtest.h`的。只能在`nix-shell`里使用gtest库：`nix-shell -p gtest`，然后在这里面编译：

```cpp
#include <iostream>
#include <gtest/gtest.h>
int main() {
	std::cout << "test\n";
	return 0;
}
```

```shell
g++ test.cpp -o test -lgtest
```

如果是用cmake + make编译的话，进入`nix-shell`的命令是`nix-shell -p gtest cmake`，据Nick Cao说是cmake的setup hook去找依赖。之后需要把原来的`build`删掉，再重新`cmake ..`才行。

## 已知的问题

如果不自己创建`.desktop`文件，Deepin启动器里好像没法找到安装的GUI软件：<https://www.bilibili.com/video/av335652600/>。不知道其他系统是不是这样。

### `error: opening lock file '/nix/var/nix/profiles/per-user/searchstar/profile.lock': No such file or directory`

在ArchLinux上出现。原因未知。可以手动创建该目录解决：

```shell
sudo mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER
sudo chown $USER:$USER /nix/var/nix/{profiles,gcroots}/per-user/$USER
```

参考：<https://discourse.nixos.org/t/per-user-profiles-not-created-when-home-mounted-on-nfs/5864/4>
