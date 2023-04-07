---
title: 用Rust的风格写C++
date: 2023-02-15 14:37:44
tags:
---

本文持续更新。

## 代码风格

### 函数返回值类型后置

C++11引入了函数返回值类型后置的写法(trailing return type)：<https://en.wikipedia.org/wiki/Trailing_return_type>

```cpp
auto func(int i, int j, int k) -> int {
	printf("2333");
	return 2333;
}

auto func(
	int i, int j, int k, int a, int b, int c, int d, int e, int f, int g, int h
) -> int {
	return 2333;
}

auto func(
	int i, int j, int k
) -> AVeryVeryLoooooooooooooooooooooooooooooooooooooooooooongType {
	return 2333;
}

auto func(
	int i, int j, int k
) -> std::tuple<
	Arg1,
	Arg2,
	...
	ArgN
> {
	return xxx;
}
```

### 构造器

```cpp
ClassA(int a, int b, int c) : a_(a), b_(b), c_(c) {}
ClassA(
	int aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
	int bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
) : a_(aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa),
	b_(bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb)
{
	// Constructor body
}
```

### （不推荐）`.clang-format`

```yaml
# <https://clang.llvm.org/docs/ClangFormatStyleOptions.html>

AlwaysBreakTemplateDeclarations: Yes

AllowShortIfStatementsOnASingleLine: Never
AllowShortLoopsOnASingleLine: false
IndentWidth: 4
UseTab: Always
TabWidth: 4
IndentAccessModifiers: false
AccessModifierOffset: -4

AlignAfterOpenBracket: BlockIndent
ContinuationIndentWidth: 4
ConstructorInitializerIndentWidth: 4
...
```

`AlignAfterOpenBracket: BlockIndent`表示将圆括号里的东西按照block的风格来align：<https://stackoverflow.com/questions/71710337/how-to-make-clang-format-not-align-parameters-to-function-call>。但是它需要安装clang-format 14。Debian 11提供的clang-format的版本是11，可以用`nix`安装最新版的clang-format：`nix-env -iA nixpkgs.clang-tools`，nix包管理器教程：{% post_link App/'使用国内源安装和使用Nix包管理器' %}

```shell
find . -regex '.*\.\(cpp\|hpp\|cc\|cxx\)' -exec clang-format -style=file -i {} \;
# https://stackoverflow.com/questions/4210042/how-do-i-exclude-a-directory-when-using-find
# 如果要排除某目录的话
find . -regex '.*\.\(cpp\|hpp\|cc\|cxx\)' -not -path "./子目录/*" -exec clang-format -style=file -i {} \;
```

存在的问题：

- 后置返回值如果太长的话会崩

```cpp
auto func(
	int i, int j, int k, int a, int b, int c, int d, int e, int f, int g, int h
)
	-> std::tuple<
		int, int, int, int, int, int, int, int, int, int, int, int, int, int> {
	return xxx;
}
```

因为目前`BlockIndent`只对圆括号起作用，对尖括号不起作用。

- 参数太短而返回值太长的话会崩

```cpp
auto func(int i, int j, int k)
	-> AVeryVeryLoooooooooooooooooooooooooooooooooooooooooooongType {
	return 2333;
}
```

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

### （不推荐）template struct

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

但是这种方法要求所有的template class的specialization都在同一个namespace里。这可能会导致链接冲突，比方说在两个不同的obj文件分别specialize了`Print<const A&>`。

### `CPO + tag_invoke`

CPO: Customization Point Object.

详细的讲解：[c++ execution 与 coroutine （一) : CPO与tag_invoke](https://zhuanlan.zhihu.com/p/431032074)

这里简单归纳一下。

#### 背景

ADL (Argument Dependent Lookup)是指，如果有限定地调用某个函数时，比如`lib::print`，那么只会在限定的namespace里查询该函数。如果在没有限定(unqualified)地调用某个函数时，比方说`print(x, y)`，那么编译器不仅会在调用点的namespace里查询有没有叫做`print`的函数，也会在x和y的namespace里查询有没有叫做`print`的函数。如果x和y是实例化的模板的话，还会从模板参数所在的namespace里查询有没有叫做`print`的函数。

例子：

```cpp
#include <iostream>
#include <vector>
namespace lib {
template <typename T>
void print(T x) {
	std::cout << x;
}
template <typename T>
void print(const std::vector<T>& v) {
	for (const auto& x : v) {
		print(x);
	}
}
}
struct A {int x;};
std::ostream& operator<<(std::ostream& out, const A& a) {
	out << a.x;
	return out;
}
void print(const A& a) {
	std::cout << "{x:" << a.x << "}";
}
int main() {
	std::vector<A> v({A{2}, A{3}, A{4}});
	lib::print(v);
	return 0;
}
```

输出：`{x:2}{x:3}{x:4}`。`lib::print`只会去`lib`中找`print`，显然找到的是`void print(const std::vector<T>& v)`。然后在里面调用`print(x)`时，因为`x`的类型是`const A&`，所以会去`A`所在的namespace里找`print`，显然找到的是`void print(const A& a)`，然后就顺利打印出来了。

但是如果我们在`main`函数里这样：

```cpp
lib::print(A{2});
```

那么C++只会去`lib`里找`print`，找到的就是`void print(T x)`了。因此打印出来的就是`2`，而不是`{x:2}`。但是显然这时调用`void print(const A& a)`是更合理的选择。

#### CPO (Customization Point Object)

CPO的目标是将原本的有限定的函数调用变成无限定的函数调用，而库只提供调用的接口。比如用CPO来实现`lib::print`：

```cpp
#include <iostream>
#include <vector>
namespace lib {
namespace detail {
struct print_t {
	template <typename T>
	void operator()(T x) {
		print(x);
	}
};
template <typename T>
void print(T x) {
	std::cout << x;
}
template <typename T>
void print(const std::vector<T>& v) {
	for (const auto& x : v) {
		print(x);
	}
}
} // namespace detail
inline detail::print_t print{};
} // namespace lib
struct A {int x;};
std::ostream& operator<<(std::ostream& out, const A& a) {
	out << a.x;
	return out;
}
void print(const A& a) {
	std::cout << "{x:" << a.x << "}";
}
int main() {
	lib::print(A{2});
	return 0;
}
```

这时`lib::print`变成了一个对象(object)，`lib::print(A{2})`变成了调用`lib::detail::print_t::()`，在里面调用了`print(x)`，它是无限定的，所以既会在调用点的namespace（即`lib::detail`）里找`print`，也会在其参数的类型（即`const A&`）的namespace里找，所以顺利找到了`void print(const A& a)`，并且打印出来了`{x:2}`。

可以看到，对于纯CPO的方式，如果某个类想要实现`lib`提供的`print`的接口，那么必须在其namespace中预留`print`的名字。这就会带来一个问题，假如另一个库`lib2`也提供了`print`接口，而某个类想要同时实现`lib::print`和`lib2::print`的接口，就会导致命名冲突。

#### `tag_invoke + CPO`

`tag_invoke`可以解决纯CPO的命名冲突，思路是让所有接口都通过`tag_invoke`实现，而调用时通过tag来指定具体要调用哪个实现。上面的例子用`tag_invoke + CPO`重写：

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
	std::cout << x;
}
template <typename T>
void tag_invoke(print_t, const std::vector<T>& v) {
	for (const auto& x : v) {
		tag_invoke(print_t{}, x);
	}
}
} // namespace detail
template <auto& Tag>
using tag_t = std::decay_t<decltype(Tag)>;
inline detail::print_t print{};
} // namespace lib
struct A {int x;};
std::ostream& operator<<(std::ostream& out, const A& a) {
	out << a.x;
	return out;
}
void tag_invoke(lib::tag_t<lib::print>, const A& a) {
	std::cout << "{x:" << a.x << "}";
}
int main() {
	std::vector<A> v({A{2}, A{3}, A{4}});
	lib::print(v);
	std::cout << std::endl;
	lib::print(A{2});
	return 0;
}
```

可以看到，这里的`lib::detail::print_t`成了tag，用于区分`tag_invoke`的各个实现。这个tag是在`detail`里的，所以另外提供了`std::tag_t`用来从接口（也就是`lib::print`）取得tag的类型。

输出：

```text
{x:2}{x:3}{x:4}
{x:2}
```

相关：<https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2021/p2279r0.html>

#### `tag_invoke + type tag`

如何利用`tag_invoke`实现反序列化（deserialize）呢？理想的tag应该是这样的：

```cpp
struct deserialize_t {
	template <typename T>
	T operator()(std::string_view x) {
		return tag_invoke(deserialize_t{}, x);
	}
};
```

但是C++目前无法根据返回值来推断`T`的类型，例如下面这段代码无法通过编译：

```cpp
#include <iostream>
using namespace std;
struct A {
	A() { std::cout << 233; }
};
struct B {
	template <typename T>
	T operator()() {
		return T();
	}
};
int main() {
	B()();
	return 0;
}
```

```text
template_operator.cpp: In function ‘int main()’:
template_operator.cpp:16:12: error: no match for call to ‘(B) ()’
   16 |         B()();
      |         ~~~^~
template_operator.cpp:10:11: note: candidate: ‘template<class T> T B::operator()()’
   10 |         T operator()() {
      |           ^~~~~~~~
template_operator.cpp:10:11: note:   template argument deduction/substitution failed:
template_operator.cpp:16:12: note:   couldn’t deduce template parameter ‘T’
   16 |         B()();
      |         ~~~^~
```

要指定要调用的`operator()`的类型，只能这样：

```cpp
B().operator()<A>();
```

这十分麻烦。因此这里采用type tag的方式，即定义一个空的模板结构体`template <typename T> struct type_tag {};`，它的功能仅仅是作为类型`T`的tag，用来帮助编译器找到对应的模板函数。结合`tag_invoke`和type tag实现的反序列化如下:

```cpp
#include <iostream>
#include <vector>

namespace lib {
template <typename T>
struct type_tag_t {};
template <typename T>
inline constexpr type_tag_t<T> type_tag{};

namespace detail {
class deserialize_t;
template <typename T>
T tag_invoke(deserialize_t, type_tag_t<T>, std::string_view x);
struct deserialize_t {
	template <typename T>
	T operator()(type_tag_t<T>, std::string_view x) {
		return tag_invoke(deserialize_t{}, type_tag<T>, x);
	}
};
int tag_invoke(deserialize_t, type_tag_t<int>, std::string_view x) {
	return *(int *)x.data();
}
} // namespace detail
template <auto& Tag>
using tag_t = std::decay_t<decltype(Tag)>;
inline detail::deserialize_t deserialize{};
} // namespace lib

struct A {int x;};
A tag_invoke(lib::tag_t<lib::deserialize>, lib::type_tag_t<A>, std::string_view x) {
	return *(A *)x.data();
}

int main() {
	int x = 2333;
	std::string_view d((const char *)&x, sizeof(x));
	std::cout << lib::deserialize(lib::type_tag<int>, d) << std::endl;

	A a{233};
	d = std::string_view((const char *)&a, sizeof(a));
	std::cout << lib::deserialize(lib::type_tag<A>, d).x << std::endl;

	return 0;
}
```

注意，由于ADL的限制，对基础数据类型（如float）和第三方类型（即不属于调用点的namespace），无法用这种方法定义其反序列化操作。Rust也采用了这种方式，即trait的implementation要么在trait声明的地方，要么在类型定义的地方。
