---
title: Linux禁用swap
date: 2022-07-13 15:10:26
tags:
---

## `sudo swapoff -a`

这一步会立即禁用swap，但是下次重启还会启用。

## 从`/etc/fstab`中删除swap条目

## mask相关systemd unit

systemd可能会从`/etc/fstab`中的swap条目生成对应的systemd unit：<https://www.freedesktop.org/software/systemd/man/systemd.swap.html>

但是从`/etc/fstab`里把swap条目删除貌似并不会把这些swap systemd unit给禁用。所以得手动mask。先查询这些swap条目：

```shell
systemctl --type swap
```

输出：

```text
  UNIT          LOAD   ACTIVE SUB    DESCRIPTION
  dev-sda3.swap loaded active active Swap Partition

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.
1 loaded units listed. Pass --all to see loaded but inactive units, too.
To show all installed unit files use 'systemctl list-unit-files'.
```

然后把这个条目给mask：

```shell
sudo systemctl mask dev-sda3.swap
```

之后重启运行`free`就会看到swap那里为0了。

## 注意事项

这里说最好不要`systemctl mask swap.target`：<https://askubuntu.com/questions/1065503/how-to-remove-systemd-targets>

## 参考文献

<https://unix.stackexchange.com/questions/551185/how-do-i-permanently-disable-swap-on-archlinux>

<https://wiki.archlinux.org/title/swap#Disabling_swap>
