---
title: tmux基础用法
date: 2021-07-20 16:20:33
---

详细教程：<https://www.ruanyifeng.com/blog/2019/10/tmux.html>

## 新建会话

```shell
tmux
```

底下的状态栏里最左边方括号里的就是自动分配的会话名称。
也可以手动指定会话名称：

```shell
tmux new -s <session-name>
```

## 关闭当前会话

`Ctrl+d`或者输入`exit`。

## 分离会话

`Ctrl+b d`，或者输入

```shell
tmux detach
```

## 查看所有会话

```shell
tmux ls
```

## 接入会话

接入上一个会话，如果没有就新建会话：

```shell
tmux attach
```

接入指定会话：

```shell
tmux attach -t <session-name>
```

t是target的缩写。

有趣的是tmux允许重复接入一个会话，而screen不行。

此外，screen不能只读接入会话，但是tmux可以（这就是我换成tmux的原因）：

```shell
tmux attach -rt <session-name>
```

## 杀死会话

杀死上一个会话：

```shell
tmux kill-session
```

杀死指定会话：

```shell
tmux kill-session -t <session-name>
```

## 复制模式

详见：[tmux复制模式使用说明](https://blog.csdn.net/yangzhongxuan/article/details/6890232)

进入复制模式：`Ctrl+b [`
退出复制模式：默认是`Esc`
默认是上下左右箭头来移动光标的。但是可以通过在`~/.tmux.conf`里加入

```shell
set-window-option -g mode-keys vi
```

来设置成vi风格的光标操作方式，需要关闭所有的tmux会话，再重新打开才能生效。注意这个时候退出复制模式的快捷键变成了`Enter`。
在vi风格的光标操作方式中，可以`ctrl+u`或者`PgUp`上翻页，`ctrl+d`或者`PgDn`下翻页，这在默认设定中好像是做不到的。

进入复制模式之后，按空格选择要复制的起始位置，然后移动光标到要复制的结束位置，然后按`Enter`复制，同时退出复制模式，按`ctrl+]`可以粘贴（只能在tmux内粘贴）。

复制模式中，虽然不再显示新的输出，但是其实程序仍然在跑，在退出复制模式后新的输出就会显示出来。

## 参考文献

<https://unix.stackexchange.com/questions/13787/is-there-a-way-to-run-screen-in-read-only-mode>
