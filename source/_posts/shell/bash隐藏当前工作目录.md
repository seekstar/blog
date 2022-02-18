---
title: bash隐藏当前工作目录
date: 2021-10-20 15:56:07
---

详细教程：<https://blog.csdn.net/xjwJava/article/details/8687969>

查看当前的设置：

```shell
echo $PS1
```

我的结果：

```
\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$
```

然后把里面的`\w`去掉就好了：

```shell
export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\[\033[00m\]\$"
```

效果：

```
searchstar@searchstar-PC:$Command here
```

如果想要极致精简，可以这样：

```shell
export PS1="$ "
```

效果：

```
$ Command here
```

相关链接：<https://askubuntu.com/questions/16728/hide-current-working-directory-in-terminal>
