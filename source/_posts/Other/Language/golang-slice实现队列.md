---
title: golang slice实现队列
date: 2022-05-09 15:17:23
tags:
---

golang的slice相当于对一段连续空间的引用。当底层数组的前面一段空间没有被任何slice引用时，这段连续空间可以被释放。用一个小实验证明这一点：

```go
package main

import (
	"fmt"
	"runtime"
	"time"
)

func main() {
	a := make([]bool, 5000000000)
	{
		a0 := &a[0]
		fmt.Printf("%v\n", *a0)
		for i := 0; i < len(a); i++ {
			a[i] = true
		}
		fmt.Printf("%v\n", a[len(a) - 10])
		fmt.Printf("%d %d\n", len(a), cap(a))
		a = a[len(a) - 100:]
		fmt.Printf("%v\n", a[len(a) - 10])
		fmt.Printf("%d %d\n", len(a), cap(a))
		runtime.GC()
		time.Sleep(10 * time.Second)
	}
	fmt.Printf("a0 released\n")
	runtime.GC()
	time.Sleep(10 * time.Second)
}
```

编译运行之后，可以看到内存使用量在`a0`被释放之后就减少了，这说明`a0`被释放之后，`a`的底层数组的前面没有被slice引用的部分的空间就会被回收了。

因此在go语言里用slice实现队列不会导致内存泄漏（前提是前面没有被slice引用的部分也没有被其他地方引用）。pop的时候直接`a = a[1:]`即可。
