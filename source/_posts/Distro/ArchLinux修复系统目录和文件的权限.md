---
title: ArchLinux修复系统目录和文件的权限
date: 2022-07-11 10:04:29
tags:
---

有时会出现本地目录权限与包里的目录权限不一致的情况。这时可以使用`pacman-fix-permissions`来修复系统目录权限：

```shell
yay -S pacman-fix-permissions
sudo pacman-fix-permissions
```

```text
...
==> Scan completed. Broken permissions in your filesystem:
/var/lib/AccountsService: 0o775 => 0o755
/var/lib/AccountsService/icons: 0o775 => 0o755
/usr/lib/utempter/utempter: 0o2755 => 0o2711
/usr/lib/systemd/system: 0o755 => 0o775
/usr/lib/systemd/system-generators: 0o755 => 0o775
/etc/proxychains.conf: 0o777 => 0o644
/usr/bin/newgidmap: 0o755 => 0o4755
/usr/bin/newuidmap: 0o755 => 0o4755
==> Apply? (yes/no)
yes
==> Done!
```

但是这个工具似乎不能修复`/`的权限错误，需要手动修复一下。（据`#archlinux-cn:nichi.co`群的`shootingstardragon`说，flatpak存在一个有概率导致`/`的权限变成`777`的BUG）
