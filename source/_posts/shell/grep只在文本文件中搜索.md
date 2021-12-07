---
title: grep只在文本文件中搜索
date: 2020-09-13 15:57:12
tags:
---

参考：<https://stackoverflow.com/questions/9806944/grep-only-text-files>

```I```选项表示不搜索binary文件。
```shell
grep -Irn string_to_search
```
