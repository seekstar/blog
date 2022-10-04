---
title: std::shared_ptr转std::unique_ptr
date: 2022-10-03 20:10:36
tags:
---

不能直接转，只能将其移动到另一个用`std::unique_ptr`管理的对象里。

```cpp
#include <iostream>
#include <memory>
int main() {
	std::shared_ptr<std::string> a = std::make_shared<std::string>(std::string("test"));
	std::cout << *a << std::endl;
	std::unique_ptr<std::string> b = std::make_unique<std::string>(std::move(*a.get()));
	std::cout << *b << std::endl;
	return 0;
}
```

感谢`#cpplang:matrix.org`群聊里的`@deepbluev7:neko.dev`和`@nenomius:matrix.org`的指导。
