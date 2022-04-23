---
title: zsh和bash共用自定义配置
date: 2022-04-23 13:32:29
tags:
---

根据这个博客：<https://medium.com/@rajsek/zsh-bash-startup-files-loading-order-bashrc-zshrc-etc-e30045652f2e>，正规的做法应该是将共用的自定义配置写到`~/.profile`里，然后在`~/.profile`里根据终端的不同调用`~/.bashrc`和`~/.zshrc`。但是实际情况是，每次打开bash，`~/.bashrc`都会执行，但是`~/.profile`却不一定会执行。根据这个回答：<https://superuser.com/a/564930>，如果要在ssh登录时让`~/.profile`执行，好像需要这样：

```shell
ssh user@host bash --login -i
```

但是tab键自动补全就用不了了。而且我认为，`~/.zshrc`和`~/.bashrc`都是特化的配置文件，而`~/.profile`是通用的配置文件。我认为应该是由特化的配置文件调用通用的配置文件，而不是现在这样反过来。因此我采用了这里的方案：<https://stackoverflow.com/a/26020688>，将通用配置文件写入`~/.profile`，然后在`~/.bashrc`和`~/.zshrc`里source它。有些发行版里`~/.profile`调用了`~/.bashrc`，要把这个调用删掉，不然会导致互相调用造成死递归。

## 讨论

其实CentOS里的`~/.bash_profile`在用ssh登录时也会被调用。所以对于CentOS，其实也可以在`~/.bash_profile`里`source ~/.profile`。但是为了一致，还是统一在`~/.bashrc`里`source ~/.profile`吧。
