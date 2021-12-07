---
title: Command \algorithmic already defined
date: 2021-03-30 22:30:34
---

algorithmic包是比较老的包，与algpseudocode不兼容。
正确使用方法：
```tex
\usepackage{algorithm}
\usepackage{algorithmicx}
\usepackage{algpseudocode}
```
用algorithmicx替代algorithmic。

algorithmic里的伪代码都是大写的，algorithmicx里的伪代码是驼峰命名的，
例如algorithmic里的```\ENDIF```在algorithmicx里是```\EndIf```。

algorithmicx文档：<https://ctan.org/pkg/algorithmicx>

参考：<https://www.it610.com/article/1291975794800795648.htm>
