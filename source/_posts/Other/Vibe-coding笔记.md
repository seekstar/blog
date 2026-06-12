---
title: Vibe coding笔记
date: 2026-06-09 23:19:34
tags:
---

## zellij

一般agent没有detach之后后台运行的功能。可以在zellij session里跑agent，这样可以随时detach，让agent在后台跑。

安装：

```shell
# nixpkgs
nix-env -iA nixpkgs.zellij
```

detach: `ctrl+o d`

```shell
zellij help
# list-sessions
zellij ls
# 新建一个名字随机的session并且attach
zellij
# 新建指定名字的session
zellij -s session名字
# attach
zellij a
# attach到指定session
zellij a session名字
# delete-all-sessions: 删除所有EXITED session
zellij da
```

## opencode

比较知名的开源agent。大部分模型应该都支持。

安装：<https://opencode.ai/download>

```shell
npm i -g opencode-ai
```

关闭一个session：`ctrl+c`

```shell
# 创建并进入一个session
opencode
opencode session list
# attach到session
opencode -s <sessionID>
# 删除session
opencode session delete <sessionID>
```

## Kimi code

好像不能设置允许访问的目录。要么忍受及其繁琐的审批，要么就`/auto`全自动。好处是可以立刻使用Kimi最新发布的模型。

官网：<https://www.kimi.com/code>

安装：

```shell
curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash
```
