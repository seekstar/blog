---
title: Linux使用笔记
date: 2023-01-21 08:09:26
tags:
---

## 更改hostname

如果直接更改`/etc/hostname`的话，终端上的hostname要重启之后才会显示为新的。另一种更好的方法是用`hostnamectl`:

```shell
hostnamectl set-hostname xxxxx
```

新的hostname会被自动写入`/etc/hostname`，而且重启终端之后显示的hostname就是新的了，不需要重启操作系统。

来源：<https://www.redhat.com/sysadmin/configure-hostname-linux>

## WIFI热点

使用`linux-wifi-hotspot`即可。ArchLinux安装方式：

```shell
# archlinuxcn源
sudo pacman -S linux-wifi-hotspot
# 或者AUR
yay -S linux-wifi-hotspot
```

## KDE Connect

### 控制媒体播放

可以用手机控制电脑上的媒体播放，比如前进和后退等。把电脑连在电视上的时候比较有用。

### 发送文本

电脑KDE Connect GUI好像没有发送文本的功能，只能用命令行。先查看手机的设备名：

```shell
kdeconnect-cli -a
```

```text
- CDY-TN90: df757ff7464d6545 (paired and reachable)
```

可以看到设备名是`CDY-TN90`。然后就可以发送到这台手机了：

```shell
kdeconnect-cli --name CDY-TN90 --share-text testtest233
```

文本会被自动保存到手机剪切板。

## 安装字体

以Debian为例：

```shell
# Times New Roman
sudo apt install ttf-mscorefonts-installer
# 如果是matplotlib，还得清一下cache：https://stackoverflow.com/a/49884009
rm ~/.cache/matplotlib -rf
```

## 取色

### xcolor

点击需要取色的像素之后RBG色号会自动复制到剪切板上。不支持wayland。

### Gpick

点`Pick color`然后取色即可。不支持wayland。

### 其他不支持wayland的

- gcolor3

### 失败的尝试

- deepin-picker: 没有出现在启动器里。命令行启动之后似乎没反应

- kcolorpicker: 启动器和命令行都没找到

## sshfs

如果卡住了：

```shell
# https://superuser.com/a/943452/1677998
sudo supervisorctl stop sshfs-public
pkill -9 sshfs
fusermount -u ~/sshfs/public
sudo supervisorctl start sshfs-public
```

`man sshfs`:

```text
       For  a  more  automatic  solution, one can use the -o ServerAliveInterval=15 option mentioned above, which
       will drop the connection after not receiving a response for 3 * 15 = 45 seconds from the remote  host.  By
       also  supplying -o reconnect, one can ensure that the connection is re-established as soon as possible af‐
       terwards. As before, this will naturally lead to loss of data that was in the process  of  being  read  or
       written at the time when the connection was interrupted.
```

所以也可以这样：

```shell
[program:sshfs-public]
command=sshfs -f -o reconnect,ConnectTimeout=5,ServerAliveInterval=5 charlie:/path/to/dir /home/searchstar/sshfs/public
autostart=true
autorestart=true
startretries=99999999
stderr_logfile=/tmp/sshfs-public-stderr.log
stdout_logfile=/tmp/sshfs-public-stdout.log
user=searchstar
```

```text
       -f     do not daemonize, stay in foreground.
```

参考：<https://unix.stackexchange.com/questions/14143/what-is-a-better-way-to-deal-with-server-disconnects-of-sshfs-mounts>
