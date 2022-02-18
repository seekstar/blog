---
title: C++找出多个数的最大值
date: 2020-05-01 15:00:46
tags:
---

参考：<https://codereview.stackexchange.com/questions/26100/maximum-of-three-values-in-c>

# 找出多个变量的最大值
使用C++11。
需要`algorithm`标准库
```cpp
#include <iostream>
#include <algorithm>

using namespace std;

int main() {
	int a = 1;
	int b = 2;
	int c = 3;
	cout << max({a, b, c}) << endl;

	return 0;
}
```
输出：
```
3
```

# 找出多个constexpr的最大值
参考：<https://stackoverflow.com/questions/5605142/stdmax-and-stdmin-not-constexpr>
C++14中，std::max和std::min有constexpr的版本了。
<https://en.cppreference.com/w/cpp/algorithm/min>
```cpp
#include <iostream>
#include <algorithm>

using namespace std;

constexpr int M = max({1, 2, 3});

int main() {
	char a[M];
	cout << sizeof(a) << endl;

	return 0;
}
```
用C++14编译运行，结果
```
3
```
