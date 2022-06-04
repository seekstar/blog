---
title: Linux禁用触摸屏
date: 2022-06-04 11:46:39
tags:
---

有些桌面环境比如KDE没有提供禁用触摸屏的选项。不过可以通过修改配置文件来禁用触摸屏。

编辑`/usr/share/X11/xorg.conf.d/40-libinput.conf`，找到`touchscreen`这项：

```text
Section "InputClass"
        Identifier "libinput touchscreen catchall"
        MatchIsTouchscreen "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
EndSection
```

加上`Option "Ignore" "on"`：

```text
Section "InputClass"
        Identifier "libinput touchscreen catchall"
        MatchIsTouchscreen "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
        Option "Ignore" "on"
EndSection
```

然后重启即可。

来源：[How to Disable Touch Screen on any Linux Distribution](https://www.youtube.com/watch?v=5QgfpW65SwY)
