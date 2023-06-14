---
title: mailx v15_compat配置教程
date: 2023-06-14 21:05:37
tags:
---

## 安装

```shell
# ArchLinux
sudo pacman -S s-nail
```

## `~/.mailrc`

主要参考：<https://wiki.archlinux.org/title/S-nail>

```text
# All the examples require v15-compat!
set v15-compat

# Essential setting: select allowed character sets
# (Have a look at the "Character sets" manual section)
set sendcharsets=utf-8,iso-8859-1

# A very kind option: when replying to a message, first try to
# use the same encoding that the original poster used herself!
set reply-in-same-charset
# When replying to or forwarding a message the comment and name
# parts of email addresses are removed unless this variable is set
set fullnames

# When sending messages, wait until the Mail-Transfer-Agent finishs.
set sendwait

# Only use builtin MIME types, no mime.types(5) files.
# That set is often sufficient, but look at the output of the
# `mimetype' command to ensure this is true for you, too
set mimetypes-load-control

# Default directory where we act in (relative to $HOME if not absolute)
set folder=mail
# A leading "+" (often) means: under folder
# record is used to save copies of sent messages, $DEAD is error storage
# inbox: system mailbox, by default /var/mail/$USER: file %
# $MBOX: secondary mailbox: file &
set MBOX=+mbox.mbox record=+sent.mbox DEAD=+dead.mbox
set inbox=+system.mbox

# Define some shortcuts; now one may say, e.g., file mymbo
shortcut mymbo %:+mbox.mbox \
         myrec +sent.mbox

# It can be as easy as
# (Remember USER and PASS must be URL percent encoded)
set mta=smtp://用户名:授权码@smtp.163.com \
    smtp-use-starttls

# It may be necessary to set hostname and/or smtp-hostname
# if the "SERVER" of smtp and "domain" of from do not match.
# Reading the "ON URL SYNTAX.." and smtp manual entries may be worthwhile
set from="用户名@163.com"
```

Arch wiki里还设置了`ssl-ca-file`等变量，但我这里运行后会报这种错：

```text
mail: Warning: variable superseded or obsoleted: ssl-ca-file
mail: Warning: variable superseded or obsoleted: ssl-ca-no-defaults
mail: Warning: variable superseded or obsoleted: ssl-protocol
mail: Warning: variable superseded or obsoleted: ssl-cipher-list
mail: Warning: variable superseded or obsoleted: ssl-verify
```

所以我没有设置这些ssl相关的配置，实测也能跑。

## 发邮件

echo "test mails" | mailx --subject="test" 接收人@163.com
