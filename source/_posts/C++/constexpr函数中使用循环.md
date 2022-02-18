---
title: constexpr函数中使用循环
date: 2021-12-27 22:55:23
tags:
---

从C++14开始，constexpr函数中也可以使用循环了。

```cpp
constexpr int pow(int a, int b) {
	int ans = 1;
	while (b--) {
		ans *= a;
	}
	return ans;
}
static_assert(pow(3, 4) == 81);
```

感谢`@deepbluev7:neko.dev`告知。
