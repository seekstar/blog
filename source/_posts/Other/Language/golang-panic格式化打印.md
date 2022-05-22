---
title: golang panic格式化打印
date: 2022-05-22 21:40:15
tags:
---

可以用`log.Fatalf`。但是`log.Fatalln`和`log.Fatal`不行。

也可以用`fmt.Sprintf`格式化输出到字符串，再用`panic`或者`log.Fataln`输出。
