---
title: C++获取日期时间戳
date: 2020-04-30 12:23:41
tags:
---

使用C++11里的std::chrono，自定义一个叫做days的duration。

```cpp
#include <iostream>
#include <chrono>
typedef std::chrono::duration<int, std::ratio<3600*24, 1> > days;
int main() {
	using namespace std::chrono;
	std::cout << duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count() << "ms\n";
	std::cout << duration_cast<hours>(system_clock::now().time_since_epoch()).count() << "h\n";
	std::cout << duration_cast<days>(system_clock::now().time_since_epoch()).count() << "d\n";
	return 0;
}
```

输出：

```text
1588220587696ms
441172h
18382d
```
