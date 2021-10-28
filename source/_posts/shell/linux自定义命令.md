---
title: linux自定义命令
date: 2020-02-08 17:35:58
---

```shell
alias Name='Action'
```
例子：
```shell
alias tp='trash-put'
```
其中trash-put是包trash-cli提供的一个命令，用于把文件或文件夹放入回收站。

如果要对以后每个终端都起作用，则可以把alias命令放入```~/.bashrc```或```/etc/bash.bashrc```中。放入前者则只对当前用户有效，放入后者则对所有用户都有效。然后重启终端或者使用```source ~/.bashrc```或者```source /etc/bash.bashrc```使其在当前终端立即生效。

亲测放到/etc/profile和/root/.bashrc中都不起作用，不知道为什么。
