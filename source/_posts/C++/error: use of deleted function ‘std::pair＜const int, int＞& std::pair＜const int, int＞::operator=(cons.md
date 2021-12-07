---
title: "error: use of deleted function ‘std::pair＜const int, int＞& std::pair＜const int, int＞::operator=(cons"
date: 2021-02-22 14:23:25
---

```
error: use of deleted function ‘std::pair<const int, int>& std::pair<const int, int>::operator=(const std::pair<const int, int>&)’
  c[0] = std::make_pair(1, 1);
                            ^
note: ‘std::pair<const int, int>& std::pair<const int, int>::operator=(const std::pair<const int, int>&)’ is implicitly declared as deleted because ‘std::pair<const int, int>’ declares a move constructor or move assignment operator
     struct pair
            ^~~~
```
完整代码：
```cpp
#include <iostream>
int main() {
	std::pair<const int, int> c[2];
	c[0] = std::make_pair(1, 1);
	return 0;
}
```
错误信息里说是因为定义了move constructor or move assignment，显然不对。
其实是因为```std::pair<const int, int>```里的first是const的，只能在定义的时候赋值，所以就把```operator=```给delete了。

更改成这样才是对的：
```cpp
#include <iostream>
int main() {
	std::pair<int, int> a[2];
	a[0] = std::make_pair(1, 1);
	std::pair<const int, int> ret = a[0];
	auto retp = reinterpret_cast<std::pair<const int, int> *>(a + 0);

	return 0;
}
```
把存储类型改成```std::pair<int, int>```，然后要用的时候（比如函数返回值）转化成```std::pair<const int, int>```，就不怕把```first```给更改了。

参考文献：
<https://stackoverflow.com/questions/5966698/error-use-of-deleted-function>
