---
title: linux kernel查看某一版本的代码
date: 2020-08-11 16:11:01
tags:
---

参考：
<https://stackoverflow.com/questions/28136815/linux-kernel-how-to-obtain-a-particular-version-right-upto-sublevel>

```shell
git tag -l
```
挑一个想要的版本
![在这里插入图片描述](linux%20kernel查看某一版本的代码/20200811160848539.png)
rc表示Release Candidate。（<https://www.zhihu.com/question/282995470>）

这里选择v5.3
![在这里插入图片描述](linux%20kernel查看某一版本的代码/20200811160936706.png)
就好了
![在这里插入图片描述](linux%20kernel查看某一版本的代码/20200811161014665.png)
