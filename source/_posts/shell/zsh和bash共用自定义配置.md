---
title: zsh和bash共用自定义配置
date: 2022-04-23 13:32:29
tags:
---

根据这个博客：<https://medium.com/@rajsek/zsh-bash-startup-files-loading-order-bashrc-zshrc-etc-e30045652f2e>，正规的做法应该是将共用的自定义配置写到`~/.profile`里，然后在`~/.profile`里根据终端的不同调用`~/.bashrc`和`~/.zshrc`。

有些发行版在用ssh登录时如果`~/.bash_profile`存在则会调用它而不是`~/.profile`。所以我们也可以在`~/.bash_profile`里：

```bash
[[ -f ~/.bashrc ]] && . ~/.bashrc
source ~/.profile
```

## Deepin

截至2025年2月8日，Deepin V23在登陆时不会`source $USER/.profile`：<https://bbs.deepin.org/post/202021?postId=1162011>

所以在Deepin里只能在`~/.bashrc`和`~/.zshrc`里`source ~/.profile`。Deepin里`~/.profile`调用了`~/.bashrc`，要把这个调用删掉，不然会导致互相调用造成死递归。

不过要注意每次启动`bash`都会读取`~/.bashrc`。为了避免重复`export`环境变量，我们可以这样：

```bash
if [ ! "$USER_PROFILE_SOURCED" ]; then
	source ~/.profile
	export USER_PROFILE_SOURCED=1
fi
```

## vscode

vscode的integrated terminal在启动的时候不会`source ~/.profile`。如果参照这里的方法：<https://stackoverflow.com/a/67843008>，把它变成一个login shell，那连接到remote上的时候`code`命令就没用了：

```json
  "terminal.integrated.profiles.linux": {
    "bash": {
      "path": "bash",
      // login shell. Make it source ~/.profile
      "icon": "terminal-bash",
      "args": ["-l"]
    }
  },
```

但是vscode的integrated shell会设置一个环境变量`VSCODE_SHELL_INTEGRATION=1`，这个环境变量是不会继承到子进程的，所以我们可以在`~/.bashrc`里加上以下内容，使`bash`只在vscode integrated shell里`source ~/.profile`：

```sh
if [ $VSCODE_SHELL_INTEGRATION ]; then
	. ~/.profile
fi
```
