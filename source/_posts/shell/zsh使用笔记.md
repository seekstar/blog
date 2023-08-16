---
title: zsh使用笔记
date: 2023-08-13 16:14:02
tags:
---

{post_link shell/'zsh和bash共用自定义配置' }

## 不共享历史

zsh默认会在不同的会话之间共享历史，禁用这个特性：

```shell
# https://github.com/ohmyzsh/ohmyzsh/issues/2537
echo "unsetopt share_history" >> ~/.zshrc
```

## 禁止zsh解析`*`

```shell
echo "setopt no_nomatch" >> ~/.zshrc
```

[zsh不兼容的坑-zsh:no matches found](https://www.jianshu.com/p/87d85593006e)

## 多行命令换行

`Alt`+`Enter`
