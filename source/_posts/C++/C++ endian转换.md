---
title: C++ endian转换
date: 2020-04-22 11:49:29
tags:
---

linux上可以使用`endian.h`，但是windows没有。

解决方法是使用boost，可移植性强。

# 安装
## debian系列
```shell
sudo apt install -y libboost-dev
```

# 使用
看文档：<https://www.boost.org/doc/libs/1_61_0/libs/endian/doc/conversion.html>

# 示例
```cpp
#include <iostream>
#include <inttypes.h>

#include <boost/endian/conversion.hpp>

using namespace std;

int main() {
	uint32_t x = 1;

	cout << x << endl;
	cout << boost::endian::native_to_big(x) << endl;

	return 0;
}
```
```
1
16777216
```
