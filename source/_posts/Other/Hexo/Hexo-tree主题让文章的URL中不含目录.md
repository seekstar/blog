---
title: Hexo tree主题让文章的URL中不含目录
date: 2021-11-16 20:13:11
tags:
---

默认设置中，文章的URL的格式是`域名/20xx/xx/xx/目录/子目录1/子目录2/文章名`，这样的坏处是修改文章目录的时候，文章的URL会变，如果这个URL已经分享给别人的话，别人就会发现这是一个死链。

要让文章的URL中不含目录，只需要将`_config.yml`里的`permalink`从`:year/:month/:day/:title/`改成`:year/:month/:day/:post_title/`即可。如果还想让URL中不含日期，改成`:post_title/`即可。注意这时候以前写的博客里的本地图片的链接可能会仍然带有目录，要`hexo clean && hexo g && hexo d`更新一下图片链接。

`permalink`的官方文档：<https://hexo.io/zh-cn/docs/permalinks>
