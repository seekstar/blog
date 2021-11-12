---
title: Qt pro文件中判断操作系统类型
date: 2020-04-09 00:12:53
tags:
---

参考：<https://zhidao.baidu.com/question/331182996978018685.html>

```
win32 {
    DEFINES  -= UNICODE
    LIBS += -lodbc32
}
unix {
    LIBS += -lodbc
}
```
linux属于unix
