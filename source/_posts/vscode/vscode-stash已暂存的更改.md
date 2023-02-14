---
title: vscode stash staged changes
date: 2023-02-14 12:45:33
tags:
---

在以前的vscode版本中，在`Staged changes`右键就可以选择`stash all changes`就可以把这些staged changes给stash。但是新版本把这个`stash all changes`的行为改成了stash所有更改了。

万幸的是从git 2.35开始提供了`-S | --staged`选项，`git stash -S`即可把staged changes给stash。

来源：<https://stackoverflow.com/questions/14759748/how-can-i-stash-only-staged-changes-in-git/70231955#70231955>

如果git版本不够（比如Debian 11），需要升级git。

## 从源码安装

<https://git-scm.com/download/linux>

```shell
sudo apt install gettext
wget https://www.kernel.org/pub/software/scm/git/git-2.39.1.tar.gz
tar xzf git-2.39.1.tar.gz
cd git-2.39.1
# ./configure --help
# --with-tcltk=no: 不要GUI
./configure --prefix=$HOME/.local/ --with-tcltk=no
make -j$(nproc)
make install
PATH=$PATH
git --version
```
