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

`Ord` -> `std::weak_order`, `std::strong_order` (since C++20)

注意C++中`std::weak_ordering::equivalent`不代表比较的双方可互相替换。而`std::strong_ordering::equivalent`代表比较的双方可以互相替换。

`PartialOrd` -> `std::partial_order` (since C++20)

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

## 不使用构造函数

使用`New`等static member function来构造，而将构造函数隐藏起来：

```cpp
#include <iostream>
class A {
public:
	A(const A&) = delete;
	A& operator=(const A&) = delete;
	A(A&& a) { std::cout << "Moving\n"; }
	A& operator=(A&& a) { std::cout << "Move assigning\n"; return *this; }
	~A() { std::cout << "Deconstructing\n"; }
	static A New() { return A(); }
private:
	A() { std::cout << "Constructing\n"; }
};
int main() {
	A a = A::New();
	return 0;
}
```

输出：

```text
Constructing
Deconstructing
```

可以看到只构造和析构了一次，实际上没有move assignment，所以跟使用构造函数的方法相比没有任何性能损失。

## 函数返回值类型后置

C++11引入了函数返回值类型后置的写法(trailing return type)：<https://en.wikipedia.org/wiki/Trailing_return_type>

```cpp
auto func(int i, int j, int k) -> int {
	return 2333;
}

auto func(int i, int j, int k
) -> AVeryVeryLoooooooooooooooooooooooooooooooooooooooooooongType {
	return 2333;
}

auto func(int very_very_loooooooooooooooooooooooooooooooog_arg_1,
	int very_very_loooooooooooooooooooooooooooooooog_arg_2
) -> AVeryVeryLoooooooooooooooooooooooooooooooooooooooooooongType {
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

### match

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

如果类没有默认构造函数的话（比如`std::reference_wrapper`），按照Rust的写法，这个类应该通过返回值将其从visitor中传出来。但是C++要求所有visitor的返回值类型相同，因此这种方法行不通。比如这个：

```cpp
#include <iostream>
#include <variant>

// https://en.cppreference.com/w/cpp/utility/variant/visit
template<class... Ts> struct overloaded : Ts... { using Ts::operator()...; };
// explicit deduction guide (not needed as of C++20)
template<class... Ts> overloaded(Ts...) -> overloaded<Ts...>;

template <typename Val, typename... Ts>
auto match(Val val, Ts... ts) {
	return std::visit(overloaded{ts...}, val);
}

int a = 233;
auto choose(bool err) -> std::variant<std::reference_wrapper<int>, int> {
	if (err) {
		return -1;
	} else {
		return std::ref(a);
	}
}

int main() {
	auto x = match(choose(false),
		[](std::reference_wrapper<int> x) {
			std::cout << x.get() << std::endl;
			return x;
		},
		[](int err) {
			std::cout << err << std::endl;
			throw err;
		}
	);

	return 0;
}
```

编译会报错：

```text
std::visit requires the visitor to have the same return type for all alternatives of a variant
```

其实我们可以通过`std::optional`来在外面声明一个未初始化的变量，然后在visitor里面将其初始化：

```cpp
#include <iostream>
#include <variant>
#include <optional>

// https://en.cppreference.com/w/cpp/utility/variant/visit
template<class... Ts> struct overloaded : Ts... { using Ts::operator()...; };
// explicit deduction guide (not needed as of C++20)
template<class... Ts> overloaded(Ts...) -> overloaded<Ts...>;

template <typename Val, typename... Ts>
auto match(Val val, Ts... ts) {
	return std::visit(overloaded{ts...}, val);
}

int a = 233;
auto choose(bool err) -> std::variant<std::reference_wrapper<int>, int> {
	if (err) {
		return -1;
	} else {
		return std::ref(a);
	}
}

int main() {
	std::optional<std::reference_wrapper<int>> x;
	match(choose(false),
		[&x](std::reference_wrapper<int> ret) {
			std::cout << ret.get() << std::endl;
			x = ret;
		},
		[](int err) {
			std::cout << err << std::endl;
		}
	);
	if (x.has_value()) {
		std::cout << x.value() << std::endl;
	}

	return 0;
}
```

`std::unique_ptr`也是可以的，缺点是需要多一层indirection。

参考：

<https://en.cppreference.com/w/cpp/utility/variant/visit>

<https://polomack.eu/std-variant/>

<https://www.cppstories.com/2019/10/lazyinit/>

### `std::variant::index`

可以用`index()`获取其类型的下标，用`std::get`获取对应的内容：

```cpp
#include <iostream>
#include <variant>
int main() {
	std::variant<int, float> a(2);
	// 0 (int)
	std::cout << a.index() << std::endl;
	// 2
	std::cout << std::get<0>(a) << std::endl;

	std::variant<int, float> b((float)2.33);
	// 1 (float)
	std::cout << b.index() << std::endl;
	// 2.33
	std::cout << std::get<1>(b) << std::endl;
	return 0;
}
```

## Trait

Rust可以为已存在的类型实现trait，从而为其引进新的成员函数，但是C++不能为已存在的类型定义新的成员函数。不过C++可以通过以下方式实现Rust的trait的功能：

### template struct

```cpp
#include <iostream>
struct A {
	A(int x) : x_(x) {}
	A(const A&) {
		std::cout << "Copying" << std::endl;
	}
	int x_;
};
template <typename T>
struct Print {
	static void print_type();
	static void print(T x) {
		std::cout << x << std::endl;
	}
};
template <>
struct Print<int> {
	static void print_type() {
		std::cout << "int" << std::endl;
	}
	static void print(int x) {
		std::cout << x << std::endl;
	}
};
template <>
struct Print<const A&> {
	static void print_type() {
		std::cout << "const A&" << std::endl;
	}
	static void print(const A& a) {
		std::cout << a.x_ << std::endl;
	}
};
int main() {
	// int
	Print<int>::print_type();
	// 233
	Print<int>::print(233);
	// const A&
	Print<const A&>::print_type();
	// 2333. Without copying
	Print<const A&>::print(A(2333));
	return 0;
}
```

它相当于：

```rs
struct A {
    x: i32,
}
impl A {
    fn new(x: i32) -> A {
        A { x }
    }
}
trait Print {
    fn print_type();
    fn print(self);
}
impl Print for i32 {
    fn print_type() {
        println!("i32");
    }
    fn print(self) {
        println!("{}", self);
    }
}
impl Print for &A {
    fn print_type() {
        println!("&A");
    }
    fn print(self) {
        println!("{}", self.x);
    }
}
fn main() {
	// i32
    i32::print_type();
    let x: i32 = 233;
	// 233
    x.print();
    // &A
    <&A>::print_type();
    // 2333
    A::new(2333).print();
}
```

### `tag_invoke`

这里只给个例子，讲解看这里：[c++ execution 与 coroutine （一) : CPO与tag_invoke](https://zhuanlan.zhihu.com/p/431032074)

```cpp
#include <iostream>
#include <vector>

namespace lib {
namespace detail {
struct print_t {
	template <typename T>
	void operator()(T x) {
		tag_invoke(print_t{}, x);
	}
};
template <typename T>
void tag_invoke(print_t, T x) {
	std::cout << x << std::endl;
}
template <typename T>
void tag_invoke(print_t, const std::vector<T>& v) {
	for (const T& x : v) {
		tag_invoke(print_t{}, x);
	}
}
} // namespace detail
inline detail::print_t print{};
template <auto& Tag>
using tag_t = std::decay_t<decltype(Tag)>;
} // namespace lib

class A {
public:
	A(int x) : x_(x) {}
private:
	int x_;
	friend void tag_invoke(lib::tag_t<lib::print>, const A& a);
};
void tag_invoke(lib::tag_t<lib::print>, const A& a) {
	std::cout << a.x_ << std::endl;
}

void tag_invoke(lib::tag_t<lib::print>, int x) {
	std::cout << x << std::endl;
}

int main() {
	std::vector<A> v1({A(1), A(2), A(3)});
	lib::print(v1);
	std::vector<int> v2({1, 2, 3});
	lib::print(v2);

	return 0;
}
```

相关：<https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2021/p2279r0.html>
