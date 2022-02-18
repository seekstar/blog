---
title: "warning: jobserver unavailable: using -j1. Add '+' to parent make rule."
date: 2020-04-24 18:38:07
tags:
---

参考：<https://stackoverflow.com/questions/9147196/makefile-pass-jobs-param-to-sub-makefiles>

把`make`换成`$(MAKE)`
例：
```Makefile
debug: $(OBJS)
	cd server && $(MAKE) debug && mv bin/debug/* .
```
