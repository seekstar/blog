---
title: git checkout 远程分支error
date: 2021-08-07 00:24:02
---

比如我有一个远程分支`origin/test`，正常情况下`git checkout test`的输出应该是

```
Branch 'test' set up to track remote branch 'test' from 'origin'.
Switched to a new branch 'test'
```

但是我这里输出的是

```
error: pathspec 'test' did not match any file(s) known to git.
```

原因是我这里有两个远程都有分支`test`。把其中一个远程删掉就好了。

参考文献：<https://stackoverflow.com/questions/1783405/how-do-i-check-out-a-remote-git-branch>
