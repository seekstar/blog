---
title: Latex打印行宽
date: 2021-03-01 14:52:25
tags:
---

翻自：<https://www.alecjacobson.com/weblog/?p=2576>

```tex
\usepackage{layouts}
```

然后在文章中想要打印的地方插入

```tex
textwidth: \printinunitsof{in}\prntlen{\textwidth}
linewidth: \printinunitsof{in}\prntlen{\linewidth}
```

然后编译一下，对应的地方就会以英寸为单位打印出`textwidth`和`linewidth`了。
