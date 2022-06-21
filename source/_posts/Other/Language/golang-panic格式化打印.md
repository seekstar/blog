---
title: golang panic格式化打印
date: 2022-05-22 21:40:15
tags:
---

可以用`fmt.Sprintf`格式化输出到字符串，再用`panic`输出：

```go
panic(fmt.Sprintf("cur = %d, filled = %d\n", cur, filled))
```

也可以用`log.Fatalf`：

```go
// Fatalf is equivalent to Printf() followed by a call to os.Exit(1).
func Fatalf(format string, v ...any) {
```

例子：

```go
log.Fatalf("cur = %d, filled = %d\n", cur, filled)
```

注意`log.Fatalf`不会打印trace，只会打印错误信息然后退出：<https://stackoverflow.com/questions/24809287/how-do-you-get-a-golang-program-to-print-the-line-number-of-the-error-it-just-ca>

`log.Fatalln`和`log.Fatal`跟`panic`一样没有自带格式化打印。
