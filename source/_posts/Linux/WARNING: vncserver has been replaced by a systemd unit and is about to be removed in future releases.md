---
title: "WARNING: vncserver has been replaced by a systemd unit and is about to be removed in future releases"
date: 2021-08-12 21:00:46
---

```/usr/share/doc/tigervnc/HOWTO.md```里有新版本的使用方法。这里放一下简单的用法。

```shell
sudo vim /etc/tigervnc/vncserver.users
```

里面加上一行：

```
:1=searchstar
```

其中searchstar是我的用户名，要换成你自己的用户名。

设置当前用户的vnc密码：

```shell
vncpasswd
restorecon -RFv ~/.vnc
```

开启服务：

```shell
sudo systemctl start vncserver@:1
systemctl status vncserver@:1
```

```
● vncserver@:1.service - Remote desktop service (VNC)
   Loaded: loaded (/usr/lib/systemd/system/vncserver@.service; disabled; vendor pres>
   Active: active (running) since Thu 2021-08-12 20:52:48 CST; 3s ago
  Process: 704047 ExecStart=/usr/libexec/vncsession-start :1 (code=exited, status=0/>
 Main PID: 704054 (vncsession)
    Tasks: 0 (limit: 817104)
   Memory: 2.3M
   CGroup: /system.slice/system-vncserver.slice/vncserver@:1.service
           ‣ 704054 /usr/sbin/vncsession searchstar :1
```

剩下的部分跟原来的一样。可以看这里：
<https://blog.csdn.net/qq_41961459/article/details/112909800>
