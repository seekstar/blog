---
title: debian踩坑笔记
date: 2021-06-01 23:43:52
---

## 安装

下载镜像：<http://mirrors.ustc.edu.cn/debian-cd/>
选择对应的版本和CPU类型，然后我选的```iso-dvd```，只下载```DVD-1.iso```就好了，其他的都是额外的软件包。

安装前一定要把网线拔了，因为安装过程中，即使选了镜像，```http://security.debian.org/debian-security```仍然会被使用，这特别慢。

如果不能用鼠标的话，不要用Graphical Install，要用字符界面的Install。Graphical Install里的software selection环节必须要用鼠标点击continue。

提示缺少iwlwifi firmware时，先选否，装好系统之后再装wifi驱动。

分区要选择格式化，可启动标志可以保持```关```。

网络镜像那里选否，因为我们已经把网线拔了。

相信我，不要选debian桌面环境，那个桌面连个文本文档都放不了。我选的xfce。

装完了之后，如果笔记本用了外接显示器，那笔记本自带的那个屏幕会被设置为主屏幕，上面的状态栏和下面的栏只会显示在主屏幕上，外接的那个显示器上啥都没有，坑的一批。

## 高分屏

我安装的是xfce，默认的scale是1，高分屏下字特别小。注意目前xfce的scale是越大字越小，越小字越大，跟其他桌面是反过来的。。。所以要把字调大，要在自定义的选项里把scale调成小于1的值，比如0.5。

## 换镜像源

这里换成中科大源。
编辑```/etc/apt/sources.list```，把内容替换成：

```
deb http://mirrors.ustc.edu.cn/debian stable main contrib non-free
# deb-src http://mirrors.ustc.edu.cn/debian stable main contrib non-free
deb http://mirrors.ustc.edu.cn/debian stable-updates main contrib non-free
# deb-src http://mirrors.ustc.edu.cn/debian stable-updates main contrib non-free

# deb http://mirrors.ustc.edu.cn/debian stable-proposed-updates main contrib non-free
# deb-src http://mirrors.ustc.edu.cn/debian stable-proposed-updates main contrib non-free

# security mirror
deb http://mirrors.ustc.edu.cn/debian-security/ stable/updates main non-free contrib
# deb-src http://mirrors.ustc.edu.cn/debian-security/ stable/updates main non-free contrib
```

```shell
sudo apt update
```

## 输入法

```shell
sudo apt install fcitx
```

然后可能要重新登录一下。
右键右上角的键盘图标，点击configure，就可以进入fcitx配置界面了。

### sunpinyin

```shell
sudo apt install fcitx-sunpinyin
# 然后可能要重新登录一下。
fcitx-config-gtk3
```

取消```Only Show Current Language```的勾，搜pinyin，点OK。

### rime

```shell
sudo apt install fcitx-rime
# 然后可能要重新登录一下。
fcitx-config-gtk3
```

取消```Only Show Current Language```的勾，搜rime，点OK。

然后按ctrl+空格切换到rime输入法，然后右键右上角的rime图标，```Schema List -> xx拼音-简化字```，就可以输入简体中文了。

## 安装wifi驱动

先查看当前debian的版本代号：
<https://www.debian.org/releases/index.zh-cn.html>
debian10是buster。

然后在```/etc/apt/sources.list```里加上

```
deb http://httpredir.debian.org/debian/ debian版本代号 main contrib non-free
```

比如debian10就是

```
deb http://httpredir.debian.org/debian/ buster main contrib non-free
```

```shell
sudo apt update
```

然后安装wifi驱动

```shell
sudo apt install firmware-iwlwifi
```

然后重启。

## 没有声音

<https://blog.csdn.net/chuanjizhen6999/article/details/101013021>

## 存在的一些问题

笔记本装好之后，合上盖子再打开，桌面就进不去了。这可能是debian的bug，因为我更新了一下系统就好了：

```shell
sudo apt upgrade
```

## 参考文献

<https://mirrors.ustc.edu.cn/help/debian.html>
<https://blog.csdn.net/gong_xucheng/article/details/81140727>
