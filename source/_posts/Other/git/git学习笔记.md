---
title: git学习笔记
date: 2022-10-05 16:10:45
tags:
---

{% post_link Other/git/'git回退指定个commit' %}

{% post_link Other/git/'git同步空文件夹' %}

{% post_link Other/git/'git解决sign_and_send_pubkey: signing failed: agent refused operation' %}

{% post_link Other/git/'git checkout 远程分支error' %}

## 删除未跟踪的文件

预览有哪些未跟踪的文件

```shell
git clean -dn
```

删除未跟踪的文件

```shell
git clean -df
```

来源：<https://koukia.ca/how-to-remove-local-untracked-files-from-the-current-git-branch-571c6ce9b6b1>

## cherry-pick

### 指定commit

```shell
git cherry-pick CommitHash
```

指定冲突解决方案：`--strategy-option`。如果在冲突时全部采用cherry-pick过来的commit的更改，则`--strategy-option theirs`。

来源：<https://stackoverflow.com/questions/21051850/force-git-to-accept-cherry-picks-changes>

### 一段连续的commit

```shell
git cherry-pick 开始..结束
```

注意，`开始`是不包含在内的，而`结束`是包含在内的，也就是说这是个左开右闭区间。如果要让`开始`也被包含在内，即指定一个闭区间，则：

```shell
git cherry-pick 开始^..结束
```

来源：<https://stackoverflow.com/questions/1994463/how-to-cherry-pick-a-range-of-commits-and-merge-them-into-another-branch>

## 变基

```shell
git rebase --onto <newbase> <oldbase>
```

相当于先保存当前的HEAD为`oldhead`，然后`reset --hard`到`newbase`，然后将从`oldbase`开始（不含）到`oldhead`（含）的所有commit给逐个cherry-pick过来。

来源：<https://www.atlassian.com/git/tutorials/rewriting-history/git-rebase>
