---
title: ssh ProxyCommand免密码
date: 2022-03-13 21:00:48
tags:
---

假设自己的电脑是A，跳板机是B，要访问的机器是C。首先在A上生成ssh密钥，然后把公钥放到B和C上。然后在A机器上的`.ssh/config`里进行如下配置：

```text
Host B
        HostName 在A视角下B的IP
        Port 在A视角下B的端口
        User B上的用户名
        IdentityFile 本地的ssh私钥路径

Host C
        ProxyCommand ssh -W 在B视角下C的IP:在B视角下C的端口 B
        User C上的用户名
        IdentityFile 本地的ssh私钥路径
```

然后在A机器上直接`ssh C`即可免密码登录C。

参考：

[内网穿透](https://hotarugali.github.io/2022/02/19/Technique/Net/%E5%86%85%E7%BD%91%E7%A9%BF%E9%80%8F/#2-2-SSH-%E8%B7%B3%E6%9D%BF)

<https://serverfault.com/questions/906298/ssh-proxycommand-with-same-password>
