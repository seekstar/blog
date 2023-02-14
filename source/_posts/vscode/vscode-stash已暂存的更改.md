---
title: vscode stash staged changes
date: 2023-02-14 12:45:33
tags:
---

在以前的vscode版本中，在`Staged changes`右键就可以选择`stash all changes`就可以把这些staged changes给stash。但是新版本把这个`stash all changes`的行为改成了stash所有更改了。

万幸的是从git 2.35开始提供了`-S | --staged`选项，`git stash -S`即可把staged changes给stash。

来源：<https://stackoverflow.com/questions/14759748/how-can-i-stash-only-staged-changes-in-git/70231955#70231955>
