---
title: Hexo插入图片
date: 2021-11-16 23:37:58
tags:
---

有两种方案，一种是把图片弄到图床上，一种是把图片直接放到博客所在的网站上，然后做一个站内引用。这里主要介绍后者。

先在`_config.yml`里把`post_asset_folder`设置成`true`，这样在建立文件时，Hexo会自动建立一个与文章同名的文件夹；以前的文章也可以自己手动创建同名文件夹。其实也可以不用装，直接每次都手动创建这个文件夹就好了。

如果使用的是vscode，可以看这篇博客：[vscode粘贴图片到Markdown](https://seekstar.github.io/2020/01/09/vscode%E7%B2%98%E8%B4%B4%E5%9B%BE%E7%89%87%E5%88%B0markdown/)。粘贴之后图片是以时间命名的，存储在跟md同级的目录下，可以手动移动到跟博客同名的目录里。

然后安装hexo-asset-image-fixed：

```shell
npm i hexo-asset-image-fixed --save
```

功能是将本地的图片的路径转换成博客网站里的图片的路径。

然后就可以用了。比如在编辑`解决某个问题.md`的时候，在同级目录新建一个文件夹：`解决某个问题`，然后把要插入的图片放到`解决某个问题/20190925022903920.png`，在`解决某个问题.md`里正常引用这个本地图片即可：

```md
![](解决某个问题/20190925022903920.png)
```

在`hexo d`的时候，会自动把这个本地路径重定向到博客网站里的图片的路径。

注意，如果博客标题里有空格，比如`解决 某个 问题`，那引用本地图片时应该将空格换成`%20`，这是空格在url里的编码。

```md
![](解决%20某个%20问题/20190925022903920.png)
```

但是文件夹的名字仍然是跟标题一样，为`解决 某个 问题`，空格还是空格。

参考文献：

[hexo博客图片问题](https://www.jianshu.com/p/950f8f13a36c)

[hexo文章插入本地图片的方法](https://blog.csdn.net/fitnig/article/details/106522811)

<https://stackoverflow.com/questions/41604263/how-do-i-display-local-image-in-markdown>
