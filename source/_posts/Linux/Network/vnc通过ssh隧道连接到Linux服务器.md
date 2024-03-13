---
title: vnc通过ssh隧道连接到Linux服务器
date: 2021-01-20 20:56:41
---

在deepin、ubuntu、Centos 8上测试通过。

## 约定

sshname表示在`.ssh/config`里的名字，可以是IP地址。
注：测试用的服务器的sshname都为L1707

## 服务器

### TigerVNC

TigerVNC会创建一个新的桌面环境。

#### 安装

Debian 12:

```shell
sudo apt install tigervnc-standalone-server
```

卸载

```shell
sudo apt remove tigervnc-standalone-server
sudo apt autoremove
```

Centos 8:

```shell
sudo yum install tigervnc-server.x86_64
```

#### 设置密码

```shell
vncpasswd
```

#### 启动

```shell
Xvnc :1 PasswordFile=$HOME/.vnc/passwd
```

```shell
tigervncserver
```

或者指定号码：

```shell
tigervncserver :1
```

#### 关闭

```shell
tigervncserver -kill :1
```

### TightVNC

#### 安装VNC server

debian系:

```shell
sudo apt install tightvncserver
```

#### 设置 / 重置 密码

```shell
vncpasswd
```

#### 启动VNC server

```shell
vncserver -localhost
```

`-localhost`表示只接受localhost的连接。

`Would you like to enter a view-only password (y/n)?`选`n`。

`New 'X' desktop is L1707:1`，表示新建的桌面在`:1`，端口号为`5901`。

完整输出：

```text
searchstar@L1707:~$  vncserver

You will require a password to access your desktops.

Password: 
Warning: password truncated to the length of 8.
Verify:   
Would you like to enter a view-only password (y/n)? n

New 'X' desktop is L1707:1

Creating default startup script /home/searchstar/.vnc/xstartup
Starting applications specified in /home/searchstar/.vnc/xstartup
Log file is /home/searchstar/.vnc/L1707:1.log
```

#### 关闭VNC server

使用完毕后可以关掉VNC server的session：

```shell
vncserver -kill :1
```

### X11VNC

X11VNC把当前显示器的内容共享出去。但对于没有显示器的机器，分辨率会很低：<https://www.reddit.com/r/linuxquestions/comments/5y80m0/higher_resolutions_with_x11vnc_on_headless_box/>

参考：<https://wiki.archlinux.org/title/X11vnc>

```shell
sudo apt install x11vnc
```

创建密码文件`~/.vnc/passwd`：

```shell
x11vnc -storepasswd
```

```shell
x11vnc -display :0 -localhost -usepw -forever -geometry 1920x1080
```

`-localhost`: 只允许localhost的连接请求
`-usepw`: 使用`~/.vnc/passwd`里的密码
`-forever`: 在第一个client退出后也继续监听

## 客户端

### 构建ssh隧道

语法如下：

```shell
ssh -fNL port:hostip:hostport sshname
```

将`localhost:port`的流量通过远程服务器`sshname`转发到`hostip:hostport`。

```text
-f: 后台运行。
-N: 不执行命令。用于转发端口。
-L port:host:hostport
        将本地机(客户机)的某个端口转发到远端指定机器的指定端口.  工作原理是这样的,
        本地机器上分配了一个 socket 侦听 port 端口, 一旦这个端口上有了连接, 该连接
        就经过安全通道转发出去, 同时远程主机和 host 的 hostport 端口建立连接. 可以
        在配置文件中指定端口的转发. 只有 root 才能转发特权端口.  IPv6 地址用另一种
        格式说明: port/host/hostport
```

网上很多教程上还加上了`-g`，这样本地的端口会向网络上其他机器开放，就不安全了。

对于我们的情况，命令这样写：

```shell
ssh -fNL 5901:localhost:5901 sshname
```

这样就把本地的5901端口的流量通过`sshname`转发给`localhost:5901`，也就是转发给服务器自己的5901端口了。这就实现了将服务器的5901端口映射到本地的5901端口了。

### 安装VNC viewer并查看

在vncviewer中查看`localhost:1`即可。

Debian系：

```shell
sudo apt install xtightvncviewer
vncviewer :1
```

ArchLinux:

```shell
sudo pacman -S tigervnc
vncviewer :1
```

MacOS: `brew install tigervnc-viewer`，然后打开tigervnc，在弹出的窗口里输入`localhost:1`即可。

![在这里插入图片描述](vnc通过ssh隧道连接到Linux服务器/20210120205541777.png)
就是任务栏没了。。。

当然显示出来是一片灰色也是正常的。

指定分辨率：

```shell
vncviewer :1 -geometry=1280x720
```

### 在终端中执行GUI程序

先查看`DISPLAY`环境变量是否已经设置了：

```shell
echo $DISPLAY
```

如果输出不为空，就可以直接在终端中执行GUI命令了：
![在这里插入图片描述](vnc通过ssh隧道连接到Linux服务器/20210120211001667.png)
如果输出为空说明没有设置，可以手动设置一下：

```shell
export DISPLAY=:1
```

然后执行GUI命令后窗口就会显示在之前打开的桌面上。

```shell
xclock
```

![在这里插入图片描述](vnc通过ssh隧道连接到Linux服务器/fd3f482000354813b770351771e3d084.png)

## 参考文献

<http://www.zsythink.net/archives/2450>

<https://blog.csdn.net/cuma2369/article/details/107668471>
