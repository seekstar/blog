---
title: xfce命令行设置快捷键
date: 2023-02-23 21:15:57
tags:
---

用`xfconf-query`可以实现用命令行设置快捷键。

## 命令行参数

```text
Application Options:
  -V, --version         Version information
  -c, --channel         The channel to query/modify
  -p, --property        The property to query/modify
  -s, --set             The new value to set for the property
  -l, --list            List properties (or channels if -c is not specified)
  -v, --verbose         Print property and value in combination with -l or -m
  -n, --create          Create a new property if it does not already exist
  -t, --type            Specify the property value type
  -r, --reset           Reset property
  -R, --recursive       Recursive (use with -r)
  -a, --force-array     Force array even if only one element
  -T, --toggle          Invert an existing boolean property
  -m, --monitor         Monitor a channel for property changes
```

## 查看有哪些channel

```shell
xfconf-query -l
```

其中`xfce4-keyboard-shortcuts`就是快捷键的channel。

## 查看有哪些快捷键

```shell
xfconf-query --channel xfce4-keyboard-shortcuts -lv
```

其中第一列的property就是快捷键，其中`<Primary>`是`Ctrl`，`Super`是`Win`键。第二列的value就是对应的命令。

例如：

```shell
/xfwm4/custom/<Primary><Alt>Left left_workspace_key
```

代表`Ctrl+Alt+左箭头`的快捷键是`left_workspace_key`，即移动到左边的工作区。

注意如果是同时按住`Shift`和`1`，那么实际上操作系统是识别成`Shift`+`!`的。在`xfconf-query`里，这些特殊字符是有名字的。部分符号和编码（有些是ASCII编码）和名字的对应关系如下：

| 符号 | 编码 | 名字 |
| ! | 0x21 | exclam |
| # | 0x23 | numbersign |
| $ | 0x24 | dollar |
| % | 0x25 | percent |
| @ | 0x40 | at |
| 左箭头 | 0x00ff51 | Left |
| 右箭头 | 0x00ff53 | Right |

完整的列表在这：<https://gitlab.gnome.org/GNOME/gtk/-/blob/main/gdk/keynames.txt>

## 取消快捷键

```shell
xfconf-query --reset --channel xfce4-keyboard-shortcuts --property "/xfwm4/custom/<Primary><Alt>Left"
```

## 设置新快捷键

例如将`Ctrl+Alt+左箭头`设置成让窗口占用左下角四分之一屏：

```shell
xfconf-query --create --channel xfce4-keyboard-shortcuts --property "/xfwm4/custom/<Primary><Shift><Alt>Left" --set tile_down_left_key --type string
```

但是奇怪的是，有时候重启之后有些用这种方式设置的快捷键在外接键盘上会失效，而内置键盘不会，比如`Alt+Shift+3`，即`<Shift><Alt>numbersign`。解决方法是用内置键盘使用一下这个快捷键，或者重新跑一遍`xfconf-query`命令。把同功能的快捷键`--reset`掉好像也有用？

## 参考文献

<https://docs.xfce.org/xfce/xfconf/xfconf-query>

[Creating shortcut programmatically](https://forum.xfce.org/viewtopic.php?id=13751)
