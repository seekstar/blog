---
title: 解决latex draw.io生成的pdf插入到latex后偏小的问题
date: 2021-06-13 16:23:23
---

latex中正文的字号设置成了10pt，所以将图中的字号也设置成10pt，但是导出pdf插入到latex里之后发现图偏小了，图中的字比正文里的字小得多。原本以为是draw.io和latex的字号标准不一样，但是导出为jpg再插入到latex之后却发现这个时候字体大小差不多了。所以原因就是draw.io生成的pdf本身就偏小了。解决方案就是在latex里设置`scale=1.34`，把这个偏差拉回来，其中`1.34`是目测出来的值。
