---
title: NixOS使用笔记
date: 2025-01-18 18:17:34
tags:
---

官方源：<https://channels.nixos.org/>

清华源：<https://mirrors.tuna.tsinghua.edu.cn/nix-channels>

本文使用清华源。

## 升级系统

官方文档：<https://nixos.org/manual/nixos/stable/#sec-upgrading>

一般情况下升级软件版本：

```shell
sudo nixos-rebuild switch --upgrade
```

如果要升级系统版本号，比如升级到24.11：

```shell
# sudo nix-channel --add https://channels.nixos.org/nixos-24.11 nixos
sudo nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-24.11 nixos
sudo nixos-rebuild switch --upgrade
```

每次`nixos-rebuild`会产生一个generation，便于以后回滚。这些generation引用了老版本软件，所以会阻止它们被GC掉。所以如果不需要回滚的话可以把老的generation删掉。

列出所有generation：

```shell
nixos-rebuild list-generations
```

只保留最新的generation，并且删除旧版本软件：

```shell
sudo nix-collect-garbage -d
```

## `configuration.nix`

```nix
{ config, pkgs, ... }:

{
	imports = [
		# Include the results of the hardware scan.
		./hardware-configuration.nix
	];

	boot.loader.efi.efiSysMountPoint = "/boot/efi";
	nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.searchstar = {
		isNormalUser = true;
		extraGroups = [
			"wheel" # Enable ‘sudo’ for the user.
			"networkmanager"
		]; 
	};

	# Use the systemd-boot EFI boot loader.
	boot.loader.efi.canTouchEfiVariables = true;
	boot.loader.grub = {
		enable = true;
		device = "nodev";
		efiSupport = true;
		useOSProber = true;
	};

	# Set your time zone.
	time.timeZone = "Asia/Shanghai";

	networking.networkmanager.enable = true;

	environment.systemPackages = with pkgs; [
		python3
		vim # The Nano editor is also installed by default.
		git
		openssl
		trash-cli
	]

	# Enable the X11 windowing system.
	services.xserver.enable = true;

	# Enable touchpad support (enabled default in most desktopManager).
	services.libinput.enable = true;

	# Enable CUPS to print documents.
	services.printing.enable = true;
}
```

修改之后要rebuild才能生效：

```shell
sudo nixos-rebuild switch
```

### KDE

```nix
	# Enable the X11 windowing system.
	services.xserver.enable = true;

	services.displayManager.sddm.enable = true;
	services.desktopManager.plasma6.enable = true;
```

### GNOME

```nix
	#environment.systemPackages = with pkgs; [
		# Need enable in "Extensions" of GNOME
		gnomeExtensions.tray-icons-reloaded
	#];

	# Enable the GNOME Desktop Environment.
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.desktopManager.gnome.enable = true;
```

### 中文输入法

官方文档：<https://nixos.wiki/wiki/Fcitx5>

```nix
	i18n.inputMethod = {
		enable = true;
		type = "fcitx5";
		fcitx5.addons = with pkgs; [
			rime-data
			fcitx5-rime
		];
	};
```

### flatpak

```nix
	xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-kde ];
	xdg.portal.enable = true;
	services.flatpak.enable = true;
```

### 代理

```nix
	# Configure network proxy if necessary
	networking.proxy.default = "http://127.0.0.1:端口/";
	networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
```

### 中文字体

```nix
	#environment.systemPackages = with pkgs; [
		# sans表示sans serif，即无衬线字体。粗体使用的就是无衬线字体
		noto-fonts-cjk-sans
	#];
```

注销再重新登录之后才生效。

## 允许安装非自由软件

```nix
	nixpkgs.config.allowUnfree = true;
```

然后把要安装的包名写在`environment.systemPackages = with pkgs; [`里面。常用的包：

### wechat-uos

要用命令行`wechat-uos`启动。。。
