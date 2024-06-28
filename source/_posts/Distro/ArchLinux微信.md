---
title: ArchLinux微信
date: 2023-12-22 15:17:11
tags:
---

## flatpak

原生微信。

```shell
flatpak install com.tencent.WeChat
flatpak run com.tencent.WeChat
```

也可以从系统的启动器里启动。

{% post_link App/'flatpak教程' %}

## deepin-wine-wechat

```shell
yay -S deepin-wine-wechat
```

我尝试的版本：3.9.0.28-3

如果是KDE的话，大概会报这个错：

```shell
/opt/apps/com.qq.weixin.deepin/files/run.sh
```

```text
==> Creating /home/searchstar/.deepinwine/Deepin-WeChat/PACKAGE_VERSION ...
  X Error of failed request:  BadWindow (invalid Window parameter)
  Major opcode of failed request:  20 (X_GetProperty)
  Resource id in failed request:  0x0
  Serial number of failed request:  10
  Current serial number in output stream:  10
```

相关issue: [Xorg显示服务器无法运行微信 #293](https://github.com/vufa/deepin-wine-wechat-arch/issues/293)

解决方案参考<https://wiki.archlinux.org/title/Deepin-wine>的3.1部分：

```shell
sudo pacman -S xsettingsd
cat > $HOME/.config/autostart/xsettingsd.desktop <<EOF
[Desktop Entry]
Name=xsettingsd
Exec=/usr/bin/xsettingsd
Type=Application
EOF
```

注销再重新登录就好了。

第一次启动可能会报一个serious bug的错，不用管，再启动一次就好了。

## wechat-uos

```shell
yay -S wechat-uos
```

不能直接发送剪切板里的图片，要保存到文件，再用发送文件的方式发送。

但是奇怪的是发送svg文件会失败，显示红色感叹号，但是发送其他文件就正常。

## com.qq.weixin.spark

`3.9.10deepin1-1`

源好像无了，安装不了：

```text
==> 错误： 无法下载 https://cdn.d.store.deepinos.org.cn/store/chat/com.qq.weixin.spark/com.qq.weixin.spark_3.9.10deepin1_all.deb
```

## electronic-wechat-uos-bin

非官方客户端，可能会被封号：<https://bbs.deepin.org/en/post/247302>
