---
title: 更改SSH host key
date: 2022-05-11 18:33:25
tags:
---

为了避免中间人攻击，每台SSH服务器都会生成一对公钥和私钥，在第一次连接SSH服务器时，SSH客户端会将公钥保存到`~/.ssh/known_hosts`里，以后每次登录这台服务器时都会验证服务器是否具有这个公钥对应的私钥，有的话才连上。

服务器的SSH host key存储在`/etc/ssh/`下面：

```shell
$ ls -1 /etc/ssh/ssh_host*
/etc/ssh/ssh_host_dsa_key
/etc/ssh/ssh_host_dsa_key.pub
/etc/ssh/ssh_host_ecdsa_key
/etc/ssh/ssh_host_ecdsa_key.pub
/etc/ssh/ssh_host_ed25519_key
/etc/ssh/ssh_host_ed25519_key.pub
/etc/ssh/ssh_host_rsa_key
/etc/ssh/ssh_host_rsa_key.pub
```

如果要重新生成SSH host key，可以先删除这些密钥对：

```shell
sudo trash-put /etc/ssh/ssh_host*
```

然后再重新生成：

```shell
sudo ssh-keygen -A
```

来源：<https://serverfault.com/questions/471327/how-to-change-a-ssh-host-key>
