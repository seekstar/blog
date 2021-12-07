---
title: MacOS在本地桌面打开远程服务器GUI应用
date: 2021-07-29 11:27:26
---

首先安装XQuartz：

```shell
brew install xquartz
```

安装程序会自动在```/etc/ssh/ssh_config```里加上

```
# XAuthLocation added by XQuartz (https://www.xquartz.org)
Host *
    XAuthLocation /opt/X11/bin/xauth
```

然后打开XQuartz，右键任务栏里的XQuartz图标，选择```应用程序->终端```，在里面输入

```shell
ssh -AXY username@ip
```

```-A```: ForwardAgent yes
```-X```: ForwardX11 yes
```-Y```: ForwardX11Trusted yes

注意，用系统自带的其他终端是不可以的。

登陆进去之后看一下是否成功：

```shell
echo $DISPLAY
```
如果有输出代表成功了。比如我这是```localhost:10.0```

试一下简单的GUI应用：

```shell
sudo apt install x11-apps
xclock
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/2e1e607c3d154b64b0e31c0ebf4b51cb.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxOTYxNDU5,size_16,color_FFFFFF,t_70)
注：如果是Linux，看这个：<https://blog.csdn.net/laoyouji/article/details/8091938>


参考文献：
[Mac连接远程服务器（Linux）显示GUI图形界面 | 详解](https://blog.csdn.net/SanyHo/article/details/109445509)
