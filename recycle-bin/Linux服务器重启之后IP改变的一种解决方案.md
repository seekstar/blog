---
title: Linux服务器重启之后IP改变的一种解决方案
date: 2021-07-25 18:06:01
---

一种方案是改成静态IP，但是有点麻烦。

其实还有一种方法，就是让服务器开机之后自动把IP发送给一个已知IP的服务器，这样如果重启之后一直连不上，就可以到另一个已知IP的服务器上查看发送过来的IP，从而得知服务器的新IP。具体做法如下。其中server1代表要发送IP的服务器，server2代表已知IP的服务器。

# 在server2上创建getip用户
这样就不会影响到其他用户了。创建的时候不设置密码，这样只能通过私钥连上，比较安全。

```shell
sudo useradd getip -d /home/getip
```

# 配置ssh密钥
在server1的root目录里生成公钥私钥

```shell
ssh-keygen -f /root/.ssh/id_rsa_getip
```

然后在`/root/.ssh/config`里加上

```shell
Host getip
        HostName server2的IP
        User getip
        IdentityFile /root/.ssh/id_rsa_getip
```

然后把公钥放到server2的getip用户里。因为getip用户没有密码，所以只能先变成root用户，然后变成getip用户：

```shell
sudo -s su getip
```

centos 8是把公钥放到`~/.ssh/authorized_keys`里。一定要注意server2的`~/.ssh`的权限要设置为`700`，`~/.ssh/authorized_keys`的权限要设置为`644`。

然后用server1的root用户试一下能不能登上server2的getip用户，也是为了把server2的IP放到`~/.ssh/known_hosts`里：

```shell
ssh getip
```

# 配置重启自动发送IP

方法就是在`/etc/rc.local`里加上
```shell
IPfile=$(mktemp)
nohup bash -c "sleep 10 && ip addr > $IPfile && scp $IPfile getip:~/$(date +%Y%m%d%X).txt && rm $IPfile" &
```

延时10秒是为了防止执行rc.local时网络还没有启动。

此外要记得`chmod +x /etc/rc.d/rc.local`来使得其有执行权限（rc.local里应该有提示）。其实`chmod +x /etc/rc.local`也可以，会自动跟随符号链接修改其指向的文件的权限。
