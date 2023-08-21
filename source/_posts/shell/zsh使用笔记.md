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

## 自带的`rm *`提醒

```shell
$ rm -f *
zsh: sure you want to delete all 3 files in /tmp/test [yn]?
```

明明已经用了`-f`但还是有prompt，很烦。可以这样关掉：

```shell
echo "setopt rmstarsilent" >> ~/.zshrc
```

参考：<https://github.com/ohmyzsh/ohmyzsh/issues/10268>

## 多行命令换行

`Alt`+`Enter`
