---
title: zsh和bash共用自定义配置
date: 2022-04-23 13:32:29
tags:
---

根据这个博客：<https://medium.com/@rajsek/zsh-bash-startup-files-loading-order-bashrc-zshrc-etc-e30045652f2e>，正规的做法应该是将共用的自定义配置写到`~/.profile`里，然后在`~/.profile`里根据终端的不同调用`~/.bashrc`和`~/.zshrc`。

`~/.zshrc`和`~/.bashrc`都是特化的配置文件，而`~/.profile`是通用的配置文件。我认为应该是由特化的配置文件调用通用的配置文件，而不是现在这样反过来。因此我采用了这里的方案：<https://stackoverflow.com/a/26020688>，将通用配置文件写入`~/.profile`，然后在`~/.bashrc`和`~/.zshrc`里source它。有些发行版里`~/.profile`调用了`~/.bashrc`，要把这个调用删掉，不然会导致互相调用造成死递归。

不过要注意每次启动`bash`都会读取`~/.bashrc`。为了避免重复`export`环境变量，我们可以让它只在login的时候`source ~/.profile`：

```bash
if shopt -q login_shell; then
	source ~/.profile
fi
```

有些发行版在用ssh登录时如果`~/.bash_profile`存在则会调用它而不是`~/.profile`。所以我们也可以在`~/.bash_profile`里：

```bash
source ~/.profile
```
