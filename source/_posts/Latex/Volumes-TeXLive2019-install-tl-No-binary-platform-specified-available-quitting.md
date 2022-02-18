---
title: >-
  /Volumes/TeXLive2019/install-tl: No binary platform specified/available,
  quitting.
date: 2021-04-12 15:05:28
tags:
---

我用的是TexLive2019，在macbook pro上运行
`sudo ./install-tl`
报这个错。我的解决方案是下载更新版本的TexLive 2021
官网：<http://www.tug.org/texlive/acquire-iso.html>
中科大源：<http://mirrors.ustc.edu.cn/CTAN/systems/texlive/Images/>
清华源：<https://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/Images>

安装完之后在`~/.zshrc`里加入
```shell
export PATH="$PATH:/usr/local/texlive/2021/bin/universal-darwin"
export MANPATH="$MANPATH:/usr/local/texlive/2021/texmf-dist/doc/man"
export INFOPATH="$INFOPATH:/usr/local/texlive/2021/texmf-dist/doc/info"
```
然后重启终端就可以用`xelatex`之类的了。
