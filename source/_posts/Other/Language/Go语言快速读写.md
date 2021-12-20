---
title: Go语言快速读写
date: 2021-04-16 11:51:10
---

Go语言可以用```fmt.Scan```和```fmt.Println```来读写，但是效率极低，在OJ上可能会TLE。

解决方案是使用```bufio```。
```go
func main() {
	out := bufio.NewWriter(os.Stdout)
	defer out.Flush()
	in := bufio.NewReader(os.Stdin)
	read_int := func() (x int) {
		c, _ := in.ReadByte()
		for ; c < '0'; c, _ = in.ReadByte() {
		}
		for ; c >= '0'; c, _ = in.ReadByte() {
			x = x * 10 + int(c - '0')
		}
		return
	}
	// Your code here
}
```

例子：
<https://www.luogu.com.cn/record/49546964>

参考文献
<https://www.luogu.com.cn/record/37561564>
