---
title: 在Linux上使用Mac键位
date: 2026-05-14 19:39:55
tags:
---

个人认为Mac的键位比较符合人体工程学，用`alt+c/v`来复制粘贴的体感明显比用`ctrl+c/v`舒服。在Linux上使用Mac键位可以把ctrl映射到alt键上，但我觉得这样影响范围太大了，而且键位差距跟Mac其实也比较大。另一种方案是给每个常用的应用单独设置快捷键，这样可以做到跟Mac的键位很像。这里主要给出各种常用软件设置快捷键的方法。

## KDE

设置 -> 键盘 -> 快捷键，一般只需要改`编辑`, `导航`, `文件`。上面有`导出`和`导入`的按钮，可以导出现在的快捷键，以后换电脑只需要`导入`就可以了。

不过这些快捷键应用里可能不认，在应用里还需要单独设置快捷键。

## vscode

左下角小齿轮 -> 键盘快捷方式。可以在右上角`打开键盘快捷方式(JSON)`

这里给一个不完全列表：

```json
    {
        "key": "ctrl+-",
        "command": "workbench.action.navigateBack",
        "when": "canNavigateBack"
    },
    {
        "key": "ctrl+alt+-",
        "command": "-workbench.action.navigateBack",
        "when": "canNavigateBack"
    },
    {
        "key": "alt+-",
        "command": "workbench.action.zoomOut"
    },
    {
        "key": "ctrl+-",
        "command": "-workbench.action.zoomOut"
    },
    {
        "key": "alt+=",
        "command": "workbench.action.zoomIn"
    },
    {
        "key": "ctrl+=",
        "command": "-workbench.action.zoomIn"
    },
    {
        "key": "alt+c",
        "command": "editor.action.clipboardCopyAction"
    },
    {
        "key": "ctrl+c",
        "command": "-editor.action.clipboardCopyAction"
    },
    {
        "key": "alt+v",
        "command": "editor.action.clipboardPasteAction"
    },
    {
        "key": "ctrl+v",
        "command": "-editor.action.clipboardPasteAction"
    },
    {
        "key": "alt+right",
        "command": "cursorLineEnd"
    },
    {
        "key": "alt+left",
        "command": "cursorLineStart"
    },
    {
        "key": "alt+z",
        "command": "undo"
    },
    {
        "key": "ctrl+z",
        "command": "-undo"
    },
    {
        "key": "shift+alt+z",
        "command": "redo"
    },
    {
        "key": "ctrl+shift+z",
        "command": "-redo"
    },
    {
        "key": "alt+a",
        "command": "editor.action.selectAll"
    },
    {
        "key": "ctrl+a",
        "command": "-editor.action.selectAll"
    },
    {
        "key": "meta+right",
        "command": "cursorWordRight"
    },
    {
        "key": "meta+left",
        "command": "cursorWordLeft",
        "when": "textInputFocus"
    },
    {
        "key": "ctrl+left",
        "command": "-cursorWordLeft",
        "when": "textInputFocus"
    },
```

一定要把菜单的助记符关掉，不然`alt+v`的时候会打开菜单。在设置里把下面两项都关掉：

```text
Window: Enable Menu Bar Mnemonics
Terminal › Integrated: Allow Mnemonics
```

## 终端

konsole的快捷键不知道为什么老是自己重置。建议使用ghostty。像Mac一样，要在`~/.ssh/config`里加上：

```text
Host *
        SetEnv TERM=xterm-256color
```

不然ssh之后会有一些诡异的事情。

配置文件：`~/.config/ghostty/config.ghostty`

文档：<https://ghostty.org/docs/config/keybind/reference>

可以`ghostty +list-keybinds --default`列出默认的快捷键，然后到配置文件里改。

常用：

```text
keybind = alt+c=copy_to_clipboard
keybind = alt+v=paste_from_clipboard
keybind = alt+==increase_font_size:1
keybind = alt+-=decrease_font_size:1

# Jump to the end of a word (forward)
keybind = super+right=esc:f
# Jump to the beginning of a word (backward)
keybind = super+left=esc:b
```

改完在终端右键 -> 配置 -> 重新加载配置 即可生效。

## 文本编辑器

建议用kate，直接继承KDE的快捷键设置。

gedit不支持改快捷键。

## Firefox

在地址栏输入`about:keyboard`，回车，在里面就可以改快捷键了。不过`alt+t`会打开菜单。要解决这个问题，在地址栏输入`about:config`，回车，然后在搜索框里输入`ui.key.menuAccessKey`，把18（代表alt）改成0，这样菜单就不会被触发了。需要使用菜单的时候再改回18即可。反正菜单用的少，应该没什么问题。

不过复制和粘贴不知道为什么还是不work，还得用`ctrl+c/v`。

参考：

<https://support.mozilla.org/en-US/kb/customize-keyboard-shortcuts-firefox>

<https://superuser.com/a/771061>
