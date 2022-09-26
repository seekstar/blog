---
title: 可在linux字符界面使用的云盘
date: 2020-03-06 10:10:24
---

声明：本文仅供参考。本人不对任何可能造成的损失负责。

这个云盘就是坚果云。

# 开通坚果云的WebDAV功能
<https://www.jianguoyun.com/#/safety>
在`第三方应用管理`处添加应用即可。会自动生成一个密码。

# 挂载成davfs
也就是这篇文章里的方式2：<https://blog.51cto.com/3331062/2306523>
其他参考网站：<https://forums.linuxmint.com/viewtopic.php?t=233633>

用自己的普通用户身份执行以下命令：
```shell
sudo apt install -y davfs2
sudo bash -c 'echo ignore_dav_header 1 >> /etc/davfs2/davfs2.conf'
sudo bash -c 'echo https://dav.jianguoyun.com/dav/要同步的云端文件夹/ 注册邮箱 上面生成的密码 >> /etc/davfs2/secrets'
sudo bash -c 'echo https://dav.jianguoyun.com/dav/要同步的云端文件夹/ /tmp/nutstore_cloud davfs user,noauto 0 0 >> /etc/fstab'
sudo usermod -aG davfs2 $(whoami)
mkdir -p /tmp/nutstore_cloud
mount /tmp/nutstore_cloud
```
然后就会在把你要同步的云端文件夹映射到`/tmp/nutstore_cloud`。
注意安装davfs2的选项要选择yes，不然可能会出权限问题。如果不小心设置错了，可以使用`sudo dpkg-reconfigure davfs2`来重新设置。

# 与一个本地文件夹同步
到上一步其实已经就可以使用了。但是每次读取文件都要进行网络传输，非常慢，所以考虑新建一个本地文件夹，然后同步这两个本地文件夹。平时访问真正的本地文件夹，就很快了。如何同步两个本地文件夹看我另一篇文章：
<https://blog.csdn.net/qq_41961459/article/details/104658868>

假设保存下面的命令到~/software/nutstore.sh
```shell
mkdir -p /tmp/nutstore_cloud
mount /tmp/nutstore_cloud

mkdir -p ~/nutstore
bash ~/software/syncboth.sh /tmp/nutstore_cloud/ ~/nutstore/
```
则执行
```shell
bash /home/你的用户名/software/nutstore.sh
```
即可在家目录下得到要同步的文件夹。

# 开机自启
不同发行版的设置开机自启的方法不一样，请自行百度。
为了防止启动时网络服务还未开启，需要延时执行（例如延迟10s再开始）
```shell
sleep 10 && sudo -u 你的用户名 bash /home/你的用户名/software/nutstore.sh &
```
而且自启时一般无法解析`~`，所以需要把所有用到的sh文件例如syncboth.sh里的`~`换成`/home/你的用户名`
