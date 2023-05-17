---
title: 在chroot里运行sshd
date: 2023-05-17 17:57:52
tags:
---

```shell
/usr/sbin/sshd -p 端口
```

但是登录进去之后会进入non-interactive模式。这是因为chroot环境默认没有`/dev/*`和`/proc/*`等文件。可以考虑用`arch-chroot`，会自动挂载相关目录，或者也可以手动挂载：{% post_link Linux/'在chroot环境中挂载dev-proc-sys' %}

## `Missing privilege separation directory: /run/sshd`

```shell
mkdir /run/sshd
```

参考：<https://askubuntu.com/questions/1110828/ssh-failed-to-start-missing-privilege-separation-directory-var-run-sshd>
