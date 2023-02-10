---
title: Linux免Root开机自动执行命令
date: 2023-02-10 19:29:01
tags:
---

例如要在开机时自动执行`~/.rc`，有两种方法：

## `crontab -e`

在其中填入`@reboot ~/.rc`即可。

## Systemd user units

编辑`~/.config/systemd/user/rc.service`：

```ini
[Unit]
Description=Execute ~/.rc at startup

[Service]
ExecStart=bash -c "~/.rc"

[Install]
WantedBy=default.target
```

```shell
systemctl --user daemon-reload
systemctl --user enable rc.service
```

脚本的输出可以通过`journalctl -xe`查看。

注意`ExecStart=`后面第一个是可执行文件，后面都是参数，所以在这里重定向指令是没有用的，例如`ExecStart=echo test >> /tmp/test`，会被解析成`echo "test" ">>" "/tmp/test"`。

来源：<https://wiki.archlinux.org/title/systemd/User>
