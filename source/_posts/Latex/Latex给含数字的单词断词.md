---
title: Latex给含数字的单词断词
date: 2021-04-21 20:21:01
---

比方说`SHA256`，如果用
```tex
\hyphenation{SHA-256}
```
会报错`Not a letter`。

这时直接在正文里想断词的地方加`\-`即可：
`SHA\-256`
