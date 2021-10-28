---
title: git同步空文件夹
date: 2019-11-29 23:36:31
---

参考链接：https://www.iteye.com/blog/hbiao68-2103286

在这个文件夹中建立一个空的.gitignore文件就好了（可以用touch命令）

如果顶层的.gitignore中没有设置同步.gitignore文件的话，新建的这个.gitignore要写成这样才行：
```gitignore
*
!.gitignore
```

顺便提一句，顶层的.gitignore要这样写：
```gitignore
#ignore all
*
#include the directories again
!*/

!*.cpp
#......
```
“*/”代表所有的目录。相对应的，“test/”代表test目录
