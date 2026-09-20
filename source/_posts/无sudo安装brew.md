---
title: 无sudo安装Homebrew on Linux
date: 2026-09-20 10:23:04
tags:
---

```shell
git clone --depth=1 https://github.com/Homebrew/brew ~/.brew
eval "$("$HOME/.brew/bin/brew" shellenv)"
echo 'eval "$("$HOME/.brew/bin/brew" shellenv)"' >> ~/.profile
```
