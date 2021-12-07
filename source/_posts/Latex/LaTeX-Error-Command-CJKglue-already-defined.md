---
title: '! LaTeX Error: Command CJKglue already defined.'
date: 2021-04-12 15:40:50
tags:
---

把```\usepackage{CJK}```删掉，再编译就不会报错了，只会报字体不存在的warning，latex会自动替换成可用字体。

```
Package fontspec Warning: Font "STFangsong" does not contain requested Script
(fontspec)                "CJK".
```
```
LaTeX Font Warning: Some font shapes were not available, defaults substituted.
```
