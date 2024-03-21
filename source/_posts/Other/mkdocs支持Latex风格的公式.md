---
title: mkdocs支持Latex风格的公式
date: 2024-03-21 22:01:08
tags:
---

向`mkdocs.yml`里添加如下内容：

```yml
markdown_extensions:
  - pymdownx.arithmatex

extra_javascript:
  - https://cdn.jsdelivr.net/npm/mathjax@2/MathJax.js?config=TeX-AMS-MML_HTMLorMML
```

然后`$f(x)$`和`$$f(x)$$`就都能正常显示了。

我的stackoverflow回答：<https://stackoverflow.com/a/78200785/13688160>
