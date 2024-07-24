---
title: 免密码用https协议clone private github repo
date: 2024-07-24 15:56:07
tags:
---

## 创建access token

<https://github.com/settings/tokens>

权限至少要选`repo`和`read:org`。

## 安装`gh`

```shell
# ArchLinux
sudo pacman -S github-cli
# Debian
sudo apt install gh
```

## `gh auth login`

按照它的提示一步步完成即可。

也可以写一个脚本自动化这一步：

```shell
gh auth login --with-token < token.txt
# https://github.com/cli/cli/issues/4351#issuecomment-1414009402
gh auth setup-git
```
