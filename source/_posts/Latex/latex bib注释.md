---
title: latex bib注释
date: 2021-06-23 13:48:30
---

我这里`//`和`%`都不管用，bibtex都会报错。
解决方法是在不想要的域的名字前面加上`_`，例如不想要这行
```tex
doi = {10.14778/3389133.3389134},
```
就改成
```tex
_doi = {10.14778/3389133.3389134},
```

参考：<https://tex.stackexchange.com/questions/21709/comments-in-bibtex>
