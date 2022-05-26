---
title: KDE Discover禁止自动检查更新
date: 2022-05-26 13:51:03
tags:
---

文档貌似没有讲到这个：

<https://userbase.kde.org/Discover>

根据这个：<https://superuser.com/questions/1368573/how-to-disable-notification-about-updates-on-startup-in-kde-5>，开机检查更新其实是PackageKit干的。PackageKit的介绍：<https://en.wikipedia.org/wiki/PackageKit>。可以看到它只是用于允许普通用户自动更新软件而已。所以要禁止自动检查更新，只需要把PackageKit卸载：

```shell
sudo pacman -R packagekit-qt5 packagekit
```

世界清净了。

参考：

<https://www.reddit.com/r/kdeneon/comments/fu4rqs/any_way_to_stop_discover_from_checking_for/>

相关：

<https://ask.fedoraproject.org/t/is-it-safe-to-remove-plasma-discover/14285/7>
