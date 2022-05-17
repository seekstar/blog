---
title: ubuntu应用设置开机自启
date: 2020-02-15 17:43:16
---

deepin可以在启动器直接右键应用程序设置开机自启。其实ubuntu也可以设置开机自启，只需要把要自启的应用的.desktop文件放在~/.config/autostart目录下。例如如果想要gnome-system-monitor开机自启，就运行以下命令：
```shell
ln -s /usr/share/applications/gnome-system-monitor.desktop ~/.config/autostart/
```
也可以自己写desktop文件。教程自行百度。也可以参考另一篇文章
https://blog.csdn.net/qq_41961459/article/details/103844053

鸣谢：
感谢 **归零幻想** 和 **sagiri** 的指点
