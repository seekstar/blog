---
title: git学习笔记
date: 2022-10-05 16:10:45
tags:
---

- {% post_link Other/git/'git回退指定个commit' %}

- {% post_link Other/git/'git同步空文件夹' %}

- {% post_link Other/git/'git解决sign_and_send_pubkey: signing failed: agent refused operation' %}

- {% post_link Other/git/'git checkout 远程分支error' %}

## 查看unstaged changes

```shell
git diff
```

包含untracked file：

```shell
git add -N . && git diff
```

来源：<https://stackoverflow.com/a/857696/13688160>

## 取消add

```shell
git reset
```

来源：<https://stackoverflow.com/questions/348170/how-do-i-undo-git-add-before-commit>

## remote

查看remote的URL（无需联网）:

```shell
# https://stackoverflow.com/questions/4089430/how-to-determine-the-url-that-a-local-git-repository-was-originally-cloned-from
git remote get-url origin
```

## clone

指定分支

```shell
git clone -b 分支名 仓库地址
# 如果只需要这个分支的话
git clone -b 分支名 --single-branch 仓库地址
```

参考：[git clone 指定分支](https://blog.csdn.net/Steve_XiaoHai/article/details/130533676)

## tag

显示全部：`git tags`

创建：`git tag 名字`

推送：`git push origin 名字`

删除：`git tag -d 名字`

如果remote删除那么本地也删除：`git fetch origin --prune`

删除所有本地tag: `git tag | xargs git tag -d` 来源：<https://stackoverflow.com/a/19542426>

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

## stash

暂存更改：

```shell
git stash
```

列出所有stash:

```shell
git stash list
```

应用并删除最近的stash:

```shell
git stash pop
```

删除指定stash:

```shell
git stash drop stash@{0}
```

查看指定stash:

```shell
# 输出类似于git commit
git stash show stash@{0} 
```

用patch的格式打印指定stash：

```shell
# -p: --patch
git stash show stash@{0} -p
```

可以保存为patch:

```shell
# -p: --patch
git stash show stash@{0} -p > xxx.patch
```

使用patch:

```shell
git apply --3way /path/to/xxx.patch
```

`--3way`: <https://stackoverflow.com/a/47756467/13688160>

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

## submodule

```shell
# 添加
git submodule add <URL> <path>
# 更新
git submodule update --remote
# 令其reset到repo中指定的commit
# https://stackoverflow.com/questions/7882603/how-to-revert-a-git-submodule-pointer-to-the-commit-stored-in-the-containing-rep
git submodule update --init
```

删除submodule比较麻烦：

```shell
# Remove the submodule entry from .git/config
git submodule deinit -f path/to/submodule

# Remove the submodule directory from the superproject's .git/modules directory
rm -rf .git/modules/path/to/submodule

# Remove the entry in .gitmodules and remove the submodule directory located at path/to/submodule
git rm -f path/to/submodule
```

来源：<https://gist.github.com/myusuf3/7f645819ded92bda6677>

## push到不同名的远程分支

```shell
# https://stackoverflow.com/questions/19154302/git-push-to-specific-branch
git push origin localBranchName:remoteBranchName
```

## Squash commits

```shell
# -i: --interactive
git rebase <base-commit-hash> -i
```

然后第一个commit标记为`pick`，其他的都标记为`squash`，即`s`。然后退出编辑器。

然后会让你编辑新的commit的message。可以全删了然后编辑新的message，然后退出编辑器，从原来的HEAD到base commit（不含）的所有commit就都被squash成了一个commit了。

## 其他

<https://stackoverflow.com/questions/89332/how-do-i-recover-a-dropped-stash-in-git>

<https://stackoverflow.com/questions/2928584/how-to-grep-search-committed-code-in-the-git-history>
