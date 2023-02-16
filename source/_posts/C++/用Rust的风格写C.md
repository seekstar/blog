---
title: 用Rust的风格写C++
date: 2023-02-15 14:37:44
tags:
---

本文持续更新。

## Rust -> C++

`Box` -> `std::unique_ptr`

`Rc` -> `std::shared_ptr`

`Arc` -> `std::atomic<std::shared_ptr>` (since C++20)

## Move-only object

一个典型的move-only class：

```cpp
class A {
public:
	A(int v);
	A(const A&) = delete;
	A& operator=(const A&) = delete;
	A(A&& a);
	A& operator=(A&& a);
};
```

例子：

```cpp
#include <iostream>
using namespace std;
class A {
public:
	A(int v) : v_(v) {}
	A(const A&) = delete;
	A& operator=(const A&) = delete;
	A(A&& a) : v_(a.v_) {}
	A& operator=(A&& a) {
		v_ = a.v_;
		return *this;
	}
	int V() const { return v_; }
private:
	int v_;
};
int main() {
	A a(1);
	std::cout << a.V() << std::endl;
	a = A(2);
	std::cout << a.V() << std::endl;
	return 0;
}
```

尤其要注意的是，C++中moved object仍然要析构，因此在move constructor和move assignment operator中一定要把旧的object相关状态清空，从而使其析构函数成为空操作。

可以用vscode clang-tidy静态检查是否使用了moved value：`bugprone-use-after-move`。教程：{% post_link vscode/'vscode-clang-tidy' %}

## 函数返回值类型后置

C++11引入了函数返回值类型后置的写法(trailing return type)：<https://en.wikipedia.org/wiki/Trailing_return_type>

```cpp
auto func() -> int {
	return 2333;
}
```

## `Option` -> `std::optional`

### 基础用法

```cpp
#include <iostream>
#include <optional>
auto func(bool cond) -> std::optional<std::string> {
	if (cond) {
		return "2333";
	} else {
		return std::nullopt;
	}
}
int main() {
	// 2333
	std::cout << func(true).value() << std::endl;
	// 0 (false)
	std::cout << func(false).has_value() << std::endl;
	return 0;
}
```

### 比较

```cpp
#include <iostream>
#include <optional>
int main() {
	// 1
	std::cout << (std::optional<int>(2) == std::optional<int>(2)) << std::endl;
	// 1
	std::cout << (std::optional<int>(2) == 2) << std::endl;
	// 0
	std::cout << (std::optional<int>(2) == std::nullopt) << std::endl;
	return 0;
}
```

### Optional reference

`std::optional`里是不能存reference的，因为C++ reference设计的时候就是对一个对象的alias，不能在container中使用。

而`std::reference_wrapper`可以看作一个保证不为空的指针，因此可以结合`std::optional`和`std::reference_wrapper`来实现optional reference，替代裸指针：

```cpp
#include <iostream>
#include <string>
#include <optional>
auto choose(std::string& a, std::string& b, int index)
	-> std::optional<std::reference_wrapper<std::string>> {
	if (index == 0) {
		return std::ref(a);
	} else if (index == 1) {
		return std::ref(b);
	} else {
		return std::nullopt;
	}
}
int main() {
	std::string a("123");
	std::string b("456");
	// 123
	std::cout << choose(a, b, 0).value().get() << std::endl;
	// 456
	std::cout << choose(a, b, 1).value().get() << std::endl;
	// 0: false
	std::cout << choose(a, b, 2).has_value() << std::endl;
	return 0;
}
```

需要注意的是目前C++没有对`std::optional<std::reference_wrapper<T>>`进行优化，它比`T *`要多用一个字节来保存是否有值的信息：

```cpp
#include <iostream>
#include <optional>
int main() {
	// 8
	std::cout << sizeof(char *) << std::endl;
	// 16。多出来的1个字节因为做了padding所以实际占用8字节。
	std::cout << sizeof(std::optional<std::reference_wrapper<char>>) << std::endl;
	return 0;
}
```

## `enum` -> `std::variant`

```cpp
template<class... Ts> struct overloaded : Ts... { using Ts::operator()...; };
// explicit deduction guide (not needed as of C++20)
template<class... Ts> overloaded(Ts...) -> overloaded<Ts...>;

template <typename Val, typename... Ts>
auto match(Val val, Ts... ts) {
	return std::visit(overloaded{ts...}, val);
}
```

用法：

```cpp
match(value, [](Type1& type1) {
		;
	},
	[](Type2& type2) {
		;
	},
	...
	[](TypeN& typeN) {
		;
	}
);
```

例子：

```cpp
#include <iostream>
#include <variant>
#include <string>

// https://en.cppreference.com/w/cpp/utility/variant/visit
template<class... Ts> struct overloaded : Ts... { using Ts::operator()...; };
// explicit deduction guide (not needed as of C++20)
template<class... Ts> overloaded(Ts...) -> overloaded<Ts...>;

template <typename Val, typename... Ts>
auto match(Val val, Ts... ts) {
	return std::visit(overloaded{ts...}, val);
}

class A {
public:
	A() : v_(0) {}
	A(int v) : v_(v) {
		std::cout << "Initializing " << V() << std::endl;
	}
	A(const A& a) : v_(a.v_) {
		std::cout << "Copying " << V() << std::endl; }
	A(A&& a) : v_(a.v_) {
		std::cout << "Moving " << V() << std::endl;
		a.Drop();
	}
	// Explicitly delete it just in case.
	A& operator=(const A&) = delete;
	A& operator=(A&& a) {
		v_ = a.v_;
		a.Drop();
		std::cout << "Move assigning " << V() << std::endl;
		return *this;
	}
	~A() {
		if (V()) {
			std::cout << "Deconstructing " << V() << std::endl;
		}
	}
	int V() { return v_; }
private:
	void Drop() {
		v_ = 0;
	}
	int v_;
};
auto func(bool choice) -> std::variant<A, int> {
	if (choice) {
		// Initializing 1
		return A(1);
		// Moving 1
	} else {
		return 233;
	}
};
auto main() -> int {
	A a;
	std::cout << match(func(true),
		[&](A& ret) -> std::string {
			// Move assigning 1
			a = std::move(ret);
			return "A";
		},
		[&](int ret) -> std::string {
			a = A(ret);
			return "int";
		}
	) << std::endl; // A
	// 1
	std::cout << a.V() << std::endl;

	return 0;
	// Deconstructing 1
}
```

输出：

```text
Initializing 1
Moving 1
Move assigning 1
A
1
Deconstructing 1
```

参考：

<https://en.cppreference.com/w/cpp/utility/variant/visit>

<https://polomack.eu/std-variant/>
