---
title: 解决virtualbox安装debian时要下载很久的问题
date: 2020-03-03 23:09:07
---

# 安装桌面
在创建虚拟机时在网络选项中把高级选项里的“插入网线”给取消掉。或者在启动之后选择VirtualBox窗口里的设备->网络，然后把`启用网络连接`给取消勾选，这样就相当于拔网线了。

这样安装过程就只会读取安装镜像里的东西，就很快了。但是会出现DHCP设置错误。选择“现在不进行网络设置”即可。

安装完成后再“接入网线”即可。

# 不安装桌面
- 先开启网络
不知道为什么，不安装桌面时，如果一开始就把网断掉，之后就再也连不上网了。所以如果不安装桌面，应该先开启网络。
- 语言一定选英语
不然会乱码。
- 时区先随便选
- 选镜像时把网络关掉，然后不选择网络镜像并继续
- 安装完成后再把网络打开
- 修改时区
exit当前用户，然后登录到root，再看这篇文章：
<https://www.cnblogs.com/keithtt/p/7339929.html>
