---
title: C++学习笔记
date: 2020-04-03 23:33:34
---

## `.clang-format`

```yaml
# <https://clang.llvm.org/docs/ClangFormatStyleOptions.html>

IndentWidth: 4
UseTab: Always
TabWidth: 4
IndentAccessModifiers: false
AccessModifierOffset: -4
AllowShortIfStatementsOnASingleLine: Never

AlignAfterOpenBracket: DontAlign
ContinuationIndentWidth: 8
ConstructorInitializerIndentWidth: 4
...
```

例子：

```cpp
int func(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j,
		int k) { // 2 tabs
	return 2333;
}

class RouterVisCnts : public rocksdb::CompactionRouter {
public: // 顶格写
```

但是构造器有问题，期望应该是这样：

```cpp
class RouterVisCnts : public rocksdb::CompactionRouter {
public:
	RouterVisCnts(int target_level, const char *path, double delta,
			bool create_if_missing)
		:	ac_(VisCntsOpen(path, delta, create_if_missing)), not_retained_(0),
			test(0) {
		return;
	}
};
```

但是实际上被格式化为了这样：

```cpp
class RouterVisCnts : public rocksdb::CompactionRouter {
public:
	RouterVisCnts(int target_level, const char *path, double delta,
			bool create_if_missing)
		: ac_(VisCntsOpen(path, delta, create_if_missing)), not_retained_(0),
		  test(0) { // 冒号后面应该插入tab而不是一个空格
		return;
	}
};
```

## vscode插件

### [clangd](https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.vscode-clangd)

它可以显示auto变量的类型，在template里也能报错。默认情况下它以`clang FILE`的方式来parse文件。在有多个文件的工程中需要生成`compile_commands.json`告诉它文件是怎么编译的，它才能正确理解文件内容。几种生成的方式如下：

----

#### cmake

```shell
mkdir build
cd build
cmake .. -DCMAKE_EXPORT_COMPILE_COMMANDS=1
# compile_commands.json will be generated right here
```

#### 从Makefile生成

```shell
bear -- make
# compile_commands.json will be generated right here
```

----

clangd会自动在项目根目录下和build下面找`compile_commands.json`。生成完毕后重启窗口即可。

注意`clangd`会往项目根目录的`.cache/clangd`下面存一些缓存文件，所以需要在`.cache`下面建立一个内容为`*`的`.gitignore`，让git忽略`.cache`下面的文件。也可以直接在项目根目录下面的`.gitignore`里加上`.cache`。

进阶用法：[使用Clangd提升C++代码编写体验](https://zhuanlan.zhihu.com/p/566506467)

参考：<https://clangd.llvm.org/installation#project-setup>

跟微软的C/C++插件相比，clangd有如下缺点：

1. 不能Debug

2. 对header-only的工程无效，因为header-only的工程并不编译出二进制文件，所以`compile_commands.json`里什么都没有。

### C++ TestMate

可以运行和调试单个GTest测试。

## 文档

### 引用 (reference)

<https://en.cppreference.com/w/cpp/language/reference>

含reference collapsing等各种蛇皮操作：

### Value categories

<https://en.cppreference.com/w/cpp/language/value_category>

glvalue (“generalized” lvalue)

prvalue (“pure” rvalue)

xvalue (an “eXpiring” value)

lvalue

rvalue

## `std::cout`

```cpp
std::cout.width(8); //设置输出宽度
std::cout.fill(‘0’); //多余空格用0填充
std::cout.setf(std::ios::right); //设置对齐方式
```

或者临时设置：

```cpp
std::cout << std::setw(8) << std::setfill(‘0’)
```

其他常见的：

- [std::dec, std::hex, std::oct](https://en.cppreference.com/w/cpp/io/manip/hex)

## Default move constructor

如果没有自己定义的copy constructor和move constructor，而且每个member都是move constructable的，那么default move constructor就是member-wise move constructor。

来源：<https://stackoverflow.com/a/48987654>

## `std::piecewise_construct`

官方文档：<https://en.cppreference.com/w/cpp/utility/piecewise_construct>

比方说有一个不能移动也不能复制的结构体`A`：

```cpp
struct A {
	A(int, float) {}
	A(const A&) = delete;
	A(A&&) = delete;
};
```

我们要往这里面`emplace_back`：

```cpp
std::deque<std::pair<A, A>> a;
```

传统的`emplace_back`需要传入A：

```cpp
a.emplace_back(A(1, 1.0), A(1, 1.0));
```

这显然是不行的，因为A既不能复制也不能移动。

这时我们可以用`std::piecewise_construct`:

```cpp
a.emplace_back(std::piecewise_construct, std::make_tuple(1, 1.0), std::make_tuple(1, 1.0));
```

这样，它会直接在分配好的内存上用tuple里的内容作为构造函数的参数原地构造这个对象，就不需要复制或者移动了。

完整代码：

```cpp
#include <iostream>
#include <deque>
struct A {
	A(int, float) {}
	A(const A&) = delete;
	A(A&&) = delete;
};
int main() {
	std::deque<std::pair<A, A>> a;
	//a.emplace_back(A(1, 1.0), A(1, 1.0));
	a.emplace_back(std::piecewise_construct, std::make_tuple(1, 1.0), std::make_tuple(1, 1.0));
	return 0;
}
```

坑点是map的`piecewise_construct`似乎是无条件的，也就是说就算是插入失败了也会先construct这个node再将其destruct。例子：

```cpp
#include <iostream>
#include <map>
#include <cassert>
#include <tuple>

class A {
public:
	A(int x) : x_(x) {
		std::cout << "Constructing " << x_ << std::endl;
	}
	~A() { std::cout << "Destructing " << x_ << std::endl; }
private:
	int x_;
};

int main() {
	std::map<int, A> m;

	auto ret = m.emplace(std::piecewise_construct, std::make_tuple(1), std::make_tuple(1));
	assert(ret.second == true);
	ret = m.emplace(std::piecewise_construct, std::make_tuple(1), std::make_tuple(233));
	assert(ret.second == false);
	std::cout << std::endl;

	return 0;
}
```

输出：

```text
Constructing 1
Constructing 233
Destructing 233

Destructing 1
```

## 字符串和数值相互转化

参考：<https://blog.csdn.net/lxj434368832/article/details/78874108>

### C字符串 -> 数值

C字符串是以`\0`结尾的`const char *`。

#### `ato`系列

文档：<https://en.cppreference.com/w/cpp/string/byte/atoi>

```c
int       atoi( const char* str );
	(1)
long      atol( const char* str );
	(2)
long long atoll( const char* str );
	(3) 	(since C++11)
```

```cpp
int ret = atoi("123");
```

#### `strto`系列

C99提供了`strtoul`和`strtoull`将C字符串转成unsigned long和unsigned long long。文档：<https://en.cppreference.com/w/c/string/byte/strtoul>

```c
unsigned long      strtoul( const char *restrict str, char **restrict str_end,
                            int base );
unsigned long long strtoull( const char *restrict str, char **restrict str_end,
                             int base );
```

例子：

```c
unsigned long x = strtoul("233", NULL, 10);
printf("%lu\n", x); // 233
x = strtoul("0xf", NULL, 16);
printf("%lu\n", x); // 15
// 将base设置为0可以自动检测
printf("%lu\n", strtoul("233", NULL, 0)); // 233
printf("%lu\n", strtoul("0xf", NULL, 0)); // 15
```

### string -> 数值

可以用C++11里的`std::sto*`系列把string转换为基本数据类型：

| 函数 | 返回的类型 |
| ---- | ---- |
| `std::stoi` | int |
| `std::stol` | long |
| `std::stoll` | long long |
| `std::stoul` | unsigned long |
| `std::stoull` | unsigned long long |

例子：

```cpp
unsigned long x = std::stoul("233");
std::cout << x << std::endl; // 233
x = std::stoul("0xf", nullptr, 16);
std::cout << x << std::endl; // 15
// 将base设置为0可以自动检测
std::cout << std::stoul("0xf", nullptr, 0) << std::endl;
std::cout << std::stoul("233", nullptr, 0) << std::endl;
```

文档：<https://en.cppreference.com/w/cpp/string/basic_string/stoul>

同理，C++11还提供了string转signed integer的函数：<https://en.cppreference.com/w/cpp/string/basic_string/stol>

以及string转浮点数的函数：<https://en.cppreference.com/w/cpp/string/basic_string/stof>

参考：<https://stackoverflow.com/questions/1070497/c-convert-hex-string-to-signed-integer>

### 数值 -> string

C++11中可以用`std::to_string`，文档：<https://en.cppreference.com/w/cpp/string/basic_string/to_string>

```cpp
int x = 123;
std::string str = std::to_string(x);
```

## 输出字符型指针指向的地址

参考：<https://www.cnblogs.com/wxxweb/archive/2011/05/20/2052256.html>

```cpp
cout << (const void*)char_pointer << endl;
```

## 多线程

### `atomic`不能用`vector`存储

因为vector在倍增的时候需要移动元素，而atomic不是move constructable的，所以atomic不能用vector存储。但是可以用`std::deque`存储，因为它没有倍增的操作。

### 睡眠

参考：<https://www.cnblogs.com/alanlvee/p/5152936.html>

```cpp
#include<chrono>
#include<thread>
```

```cpp
//睡眠233ms
std::this_thread::sleep_for(std::chrono::milliseconds(233));
```

### Memory order

{% post_link 'C++/cpp-memory-order' %}

### CAS (Compare And Swap)

`std::atomic`通过`compare_exchange_weak`和`compare_exchange_strong`来实现CAS操作：<https://en.cppreference.com/w/cpp/atomic/atomic/compare_exchange>

基础接口：

```cpp
bool compare_exchange_weak( T& expected, T desired);
bool compare_exchange_strong( T& expected, T desired);
```

如果原子变量的值等于expected，那么就将其赋值为desired，并返回true。如果原子变量的值不等于expected，那么就将真正的值赋值到expected里，并返回false。

换言之，调用结束之后expected为原子变量中最终存的值。

`compare_exchange_weak`与`compare_exchange_strong`不同的地方在于，即使原子变量的值等于expected，`compare_exchange_weak`也可能会返回false，而`compare_exchange_strong`不会出现这种情况，但是性能可能比`compare_exchange_weak`低。因此如果CAS本来就在一个循环里，比如它来实现原子加1，那么可以直接用`compare_exchange_weak`：

```cpp
#include <iostream>
#include <thread>
#include <atomic>
#include <vector>

std::atomic<int> x;
void add1() {
	int ori;
	do {
		ori = x.load(std::memory_order_relaxed);
	} while (!x.compare_exchange_weak(ori, ori + 1, std::memory_order_relaxed));
}
int main() {
	std::vector<std::thread> ts;
	for (size_t i = 0; i < 10000; ++i)
		ts.emplace_back(add1);
	for (auto& t : ts)
		t.join();
	std::cout << x.load() << std::endl;
	return 0;
}
```

## 正则表达式

参考：<https://blog.csdn.net/philpanic9/article/details/88141305>
文档：<http://www.cplusplus.com/reference/regex/basic_regex/>

```cpp
#include <regex>
```

REGular EXpression

C++默认使用ECMAScript的正则表达式文法。
教程：<https://www.cnblogs.com/cycxtz/p/4804115.html>

### regex_match

判断是否为格式为yyyy-mm-dd的日期

```cpp
#include <iostream>
#include <regex>

using namespace std;

const regex regex_date("\\d{4}-\\d{2}-\\d{2}");
bool validDate(const string& s) {
	    return regex_match(s, regex_date);
}

int main() {
	cout << validDate("2020-04-06") << endl;
	cout << validDate("202-04-06") << endl;
	cout << validDate("20204-06") << endl;
	cout << validDate("2020-04-06-") << endl;
	cout << validDate("2020-04-6") << endl;

	return 0;
}
```

输出：

```text
1
0
0
0
0
```

### regex_search

搜索出所有连续的数字。

```cpp
#include <regex>
#include <iostream>

using namespace std;

int main() {
	regex e("\\d+");

	const char s[] = "(123, 456), (789, 452)";
	cmatch m;

	const char* now = s;
	while (regex_search(now, m, e)) {
		for (auto x : m) {
			cout << x << ' ';
		}
		cout << endl << "position: " << m.position() << endl <<  "length: " << m.length() << endl;
		now += m.position() + m.length();
	}
	cout << endl;

	string str("(123, 456), (789, 452)");
	smatch sm;
	while (regex_search(str, sm, e)) {
		for (auto x : sm) {
			cout << x << ' ';
		}
		cout << endl;
		str = sm.suffix().str();
	}

	return 0;
}
```

输出：

```text
123
position: 1
length: 3
456
position: 2
length: 3
789
position: 4
length: 3
452
position: 2
length: 3

123
456
789
452
```

### regex_replace

```cpp
#include <iostream>
#include <regex>

using namespace std;

int main() {
	string s("abcdefgdd");
	regex e("d");

	cout << regex_replace(s, e, "233") << endl;

	return 0;
}
```

输出：

```text
abc233efg233233
```

## 内存安全

### 多用智能指针

多思考ownership，尽量用`std::unique_ptr`和`std::shared_ptr`。

注意`std::unique_ptr`可以转换成`std::shared_ptr`，但是`std::shared_ptr`不能转换成`std::unique_ptr`。如果碰到某个`std::unique_ptr`需要临时共享的情况，可以强转成裸指针做。

### 注意野引用

此外，C++的引用只能保证不为NULL，但是并不能保证它一定指向一个有效的对象。例如下面的代码可以编译通过：

```cpp
#include <iostream>
struct A {
	A(int& a) : a_(a) {}
	int& a_;
};
A test() {
	int a = 233;
	return A(a);
}
int main() {
	A a = test();
	std::cout << a.a_ << std::endl;
	return 0;
}
```

而且在传入引用时看起来与传值一样。因此如果需要长期持有这个引用，例如在保存在某个结构体中，那么还是建议用裸指针，而不是引用。例如上面的例子这样写就很容易看出来有问题：

```cpp
#include <iostream>
struct A {
	A(int* a) : a_(a) {}
	int* a_;
};
A test() {
	int a = 233;
	return A(&a);
}
int main() {
	A a = test();
	std::cout << *a.a_ << std::endl;
	return 0;
}
```

### vscode clang-tidy静态检查

比如检查是否使用了moved value：`bugprone-use-after-move`

教程：{% post_link vscode/'vscode-clang-tidy' %}

### 迭代器

建议自定义迭代器时使用Rust风格的接口：

```cpp
class Iterator {
	// Return owned object
	T Next();
	// If peekable
	// Return NULL if not exists
	T* Peek();
};
```

注意`Peek`返回的object不要保存，而是每次都调用`Peek`来访问，否则会出现下次调用`Next`之后原先保存的引用失效的问题。

## 模板类分离声明和定义

```cpp
#include <iostream>

using namespace std;

template <typename T>
struct A {
	A();
	void Print();
	T a_;
};

template <typename T>
A<T>::A() : a_(233) {}

template <typename T>
void A<T>::Print() {
	std::cout << a_ << std::endl;
}

int main() {
	A<int>().Print();

	return 0;
}
```

参考：<https://stackoverflow.com/questions/2464296/is-it-possible-to-defer-member-initialization-to-the-constructor-body>

嵌套类同理：

```cpp
#include <iostream>

using namespace std;

template <typename T>
struct A {
	struct B {
		static void Print();
	};
};

template <typename T>
void A<T>::B::Print() {
	std::cout << typeid(T).name() << std::endl;
}

int main() {
	A<int>::B::Print();

	return 0;
}
```

如果已知需要用到哪些类型的话，似乎还可以把template的定义放到cpp文件：

<https://stackoverflow.com/questions/115703/storing-c-template-function-definitions-in-a-cpp-file>

## 隐藏构造函数

有时会只想让特定的函数（比如`begin()`）能够返回一个类（比如迭代器），此时就需要隐藏这个类的构造函数。

### C++20 module

这是最优雅的方法。但是却不总是可行。

### friend

把要访问隐藏的构造函数的函数和类声明为friend即可。

```cpp
#include <iostream>

using namespace std;

class A {
public:
	void Print() {
		std::cout << a_ << std::endl;
	}
private:
	A(int a) : a_(a) {}
	int a_;
	friend A Create();
};

A Create() {
	return A(233);
}

int main() {
	Create().Print();

	return 0;
}
```

{% spoiler （不推荐）引入隐藏的namespace %}

引入一个隐藏的namespace来模拟module里没有export的部分。将要隐藏的构造函数声明为`protected`，然后在隐藏的namespace里声明一个继承这个类的子类，这样这个子类就可以访问这个隐藏的构造函数。将子类的构造函数声明为`public`，需要使用隐藏的构造函数时，调用子类的构造函数，然后将构造出来的子类转换为那个类即可。

```cpp
#include <iostream>

using namespace std;

class A {
public:
	void Print() {
		std::cout << a_ << std::endl;
	}
protected:
	A(int a) : a_(a) {}
private:
	int a_;
};

// This should not be accessed by users
namespace __A {
struct _A : A {
	_A(int a) : A(a) {}
};

}

A Create() {
	return __A::_A(233);
}

int main() {
	Create().Print();

	return 0;
}
```

但是这样比较麻烦，也很丑。

{% endspoiler %}

## 返回多个对象

需要使用C++17的structured binding：

```cpp
#include <iostream>
#include <tuple>

using namespace std;

struct A {
	A() {
		std::cout << "A constructing\n";
	}
	A(A&&) {
		std::cout << "A moving\n";
	}
	A(const A&) = delete;
	~A() {
		std::cout << "A deconstructing\n";
	}
};

std::tuple<int, A> f() {
	return std::tuple(233, A());
}

int main() {
	auto [x, a] = f();
	return 0;
}
```

输出：

```text
A constructing
A moving
A deconstructing
A deconstructing
```

可见接收返回值的时候调用的是move constructor。

但是vscode显示那些返回的对象的类型是`<unnamed>`，而且也没有任何成员函数之类的提示。似乎是因为返回出来的实际上是指向返回值中的对象的引用类型，而且没有名字。所以这个特性对IDE非常不友好。

## move constructor里构造父类

```cpp
#include <iostream>

using namespace std;

struct A {
	A(int a) : a_(a) {}
	A(A&& a) : a_(a.a_) {}
	A(const A&) = delete;
	void PrintA() {
		std::cout << a_ << std::endl;
	}
	int a_;
};

struct B : A {
	B(int a, int b) : A(a), b_(b) {}
	// 直接调用父类的move constructor
	// B&&会被自动转换为A&&
	B(B&& r) : A(std::move(r)), b_(r.b_) {}
	B(const B&) = delete;
	void PrintB() {
		std::cout << b_ << std::endl;
	}
	int b_;
};

int main() {
	B b(1, 2);
	b.PrintA();
	b.PrintB();

	B c(std::move(b));
	c.PrintA();
	c.PrintB();

	return 0;
}
```

参考：<https://stackoverflow.com/questions/37668952/move-constructor-for-derived-class>

## std::optional

Since C++17.

```cpp
#include <iostream>
#include <vector>
#include <optional>

std::optional<std::vector<int>> f(bool none) {
	if (none) {
		return std::nullopt;
	} else {
		return std::vector<int>({1, 2, 3});
	}
}

int main() {
	auto ret = f(false);
	// If not none, then evaluated to true
	std::cout << (bool)ret << std::endl;
	for (int v : ret.value())
		std::cout << v << ' ';
	std::cout << std::endl;

	ret = f(true);
	// If none, then evaluated to false
	std::cout << (bool)ret << std::endl;

	return 0;
}
```

## 二分搜索

`std::lower_bound`返回第一个>=目标的元素迭代器，`std::upper_bound`返回第一个>目标的元素的迭代器：

```cpp
#include <iostream>
#include <algorithm>

using namespace std;

int main() {
	int a[] = {1, 2, 3};
	// 2
	std::cout << *std::lower_bound(a, a + sizeof(a) / sizeof(a[0]), 2) << std::endl;
	// 3
	std::cout << *std::upper_bound(a, a + sizeof(a) / sizeof(a[0]), 2) << std::endl;

	return 0;
}
```

但是`std::lower_bound`要求数组元素和目标可比较，而`std::upper_bound`要求目标和数组元素可比较。例如下面的代码可以正常使用`std::lower_bound`，因为`A`可以和目标`int`比较，但是`std::upper_bound`不能正常使用，因此`int`不能和`A`比较：

```cpp
#include <iostream>
#include <algorithm>

using namespace std;

struct A {
	int v;
	bool operator < (int b) const {
		return v < b;
	}
};

int main() {
	A a[] = {A{1}, A{2}, A{3}};
	std::cout << std::lower_bound(a, a + sizeof(a) / sizeof(A), 2)->v << std::endl;
	std::cout << std::upper_bound(a, a + sizeof(a) / sizeof(A), 2)->v << std::endl;

	return 0;
}
```

编译报错：

```text
/usr/include/c++/12.2.1/bits/predefined_ops.h:98:22: error: no match for ‘operator<’ (operand types are ‘const int’ and ‘A’)
   98 |       { return __val < *__it; }
      |
```

要修复这个问题，只需要再加一个`int`和`A`的比较函数即可：

```cpp
bool operator < (int a, const A& b) {
	return a < b.v;
}
```

也可以用C++20的三路比较来实现只需要定义一个方向的比较函数的二分搜索：

```cpp
#include <iostream>
#include <compare>

using namespace std;

struct A {
	int v;
};

struct Compare {
	std::weak_ordering operator () (A *a, int b) const {
		return a->v <=> b;
	}
};

template <typename Addable, typename T, typename ThreeWayCompare>
Addable LowerBoundAddable(Addable start, Addable end, T d, ThreeWayCompare comp) {
	while (start != end) {
		Addable mid = start + (end - start) / 2;
		if (comp(mid, d) == std::weak_ordering::less) {
			start = mid + 1;
		} else {
			end = mid;
		}
	}
	return start;
}
template <typename Addable, typename T, typename ThreeWayCompare>
Addable UpperBoundAddable(Addable start, Addable end, T d, ThreeWayCompare comp) {
	while (start != end) {
		Addable mid = start + (end - start) / 2;
		if (comp(mid, d) == std::weak_ordering::greater) {
			end = mid;
		} else {
			start = mid + 1;
		}
	}
	return start;
}

int main() {
	A a[] = {A{1}, A{2}, A{3}};
	// 2
	std::cout << LowerBoundAddable(a, a + sizeof(a) / sizeof(A), 2, Compare())->v << std::endl;
	// 3
	std::cout << UpperBoundAddable(a, a + sizeof(a) / sizeof(A), 2, Compare())->v << std::endl;

	return 0;
}
```

## 覆盖不可复制对象

比如对象`a`：

```cpp
#include <iostream>
using namespace std;
class A {
public:
	A(int v) : v_(v) {}
	A(const A&) = delete;
	A(A&& a) : v_(a.v_) {}
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

```text
overwrite_unclonable.cpp: 在函数‘int main()’中:
overwrite_unclonable.cpp:15:16: 错误：使用了被删除的函数‘constexpr A& A::operator=(const A&)’
   15 |         a = A(2);
      |                ^
overwrite_unclonable.cpp:3:7: 附注：‘constexpr A& A::operator=(const A&)’ is implicitly declared as deleted because ‘A’ declares a move constructor or move assignment operator
    3 | class A {
      |       ^
```

这是因为定义了move constructor之后就不再提供默认的copy assignment operator，但是move assignment operator又没有默认给出，因此`operator=`就没有定义了。要解决这个问题，只需要显式给出move assignment operator即可：

```cpp
	A& operator = (A&& a) {
		v_ = a.v_;
		return *this;
	}
```

保险起见，最好把copy assignment operator给显式delete掉：

```cpp
	A& operator=(const A&) = delete;
```

## 调用基类的operator

`对象.基类::operator=(派生类对象)`

例如：

```cpp
class B {
public:
	B& operator = (B&& b) {
		std::cout << "B\n";
		return *this;
	}
};
class A : B {
	A& operator=(A&& a) {
		B::operator=(std::move(a));
		v_ = a.v_;
		return *this;
	}
}
```

完整代码：

```cpp
#include <iostream>
using namespace std;
class B {
public:
	B& operator = (B&& b) {
		std::cout << "B\n";
		return *this;
	}
};
class A : B {
public:
	A(int v) : v_(v) {}
	A(const A&) = delete;
	A(A&& a) : v_(a.v_) {}
	A& operator=(A&& a) {
		B::operator=(std::move(a));
		v_ = a.v_;
		return *this;
	}
	A& operator=(const A&) = delete;
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

## 文件管理

### 新建文件

```cpp
// 如果文件已存在就将长度截断为0
std::fstream f(path);
// 如果文件已存在就将长度截断为0
std::ofstream f(path);
// 如果文件已存在则保持原样
std::fstream f(path, std::ios::app);
```

完整版: <https://en.cppreference.com/w/cpp/io/basic_filebuf/open>

注意open mode里如果有`std::ios::in`的话，就不会自动新建文件了。

### 删除文件

```cpp
// 删除单个文件或者空目录。如果删除成功，则返回true，如果文件不存在，则返回false
bool std::filesystem::remove(const std::filesystem::path& p);
// 删除目录或文件。返回删除的目录或文件的个数。如果p一开始就不存在，则返回0。
std::uintmax_t remove_all(const std::filesystem::path& p);
```

文档：<https://en.cppreference.com/w/cpp/filesystem/remove>

## boost

### program_options

可以处理命令行参数。

官方文档：<https://www.boost.org/doc/libs/1_82_0/doc/html/program_options.html>

```shell
# Debian 11
sudo apt install libboost-program-options-dev
# Arch Linux
sudo pacman -S boost
```

例子：

```cpp
#include <iostream>
#include <boost/program_options.hpp>

int main(int argc, char **argv) {
	namespace po = boost::program_options;
	po::options_description desc("Available options");
	std::string format;
	bool use_direct_reads;
	std::string db_path;
	desc.add_options()
		("help", "Print help message")
		("cleanup,c", "Empty the directories first.")
		(
			"format,f", po::value<std::string>(&format)->default_value("ycsb"),
			"Trace format: plain/ycsb"
		) (
			"use_direct_reads",
			po::value<bool>(&use_direct_reads)->default_value(true), ""
		) (
			"db_path", po::value<std::string>(&db_path)->required(),
			"Path to database"
		) (
			"level0_file_num_compaction_trigger", po::value<int>(),
			"Number of files in level-0 when compactions start"
		);
	po::variables_map vm;
	po::store(po::parse_command_line(argc, argv, desc), vm);
	if (vm.count("help")) {
		std::cerr << desc << std::endl;
		return 0;
	}
	po::notify(vm);

	if (vm.count("cleanup")) {
		std::cerr << "cleanup\n";
	}
	std::cerr << format << std::endl;
	std::cerr << "use_direct_reads: " << use_direct_reads << std::endl;
	std::cerr << "db_path: " << db_path << std::endl;
	if (vm.count("level0_file_num_compaction_trigger")) {
		std::cerr << vm["level0_file_num_compaction_trigger"].as<int>()
			<< std::endl;
	}
	return 0;
}
```

```shell
g++ program-options.cpp -lboost_program_options -o program-options
./program-options --help
```

```text
Available options:
  --help                                Print help message
  -c [ --cleanup ]                      Empty the directories first.
  -f [ --format ] arg (=ycsb)           Trace format: plain/ycsb
  --use_direct_reads arg (=1)
  --db_path arg                         Path to database
  --level0_file_num_compaction_trigger arg
                                        Number of files in level-0 when
                                        compactions start
```

参考文献：<https://stackoverflow.com/questions/5395503/required-and-optional-arguments-using-boost-library-program-options>

## 执行命令

`std::system`: <https://en.cppreference.com/w/cpp/utility/program/system>

当前线程会一直阻塞到命令完成。如果想要非阻塞的话，可以在命令的最后加一个`&`，让它在后台执行。当前进程退出时这个后台进程会自动被杀掉。

## Non-portable

给线程取名字：

用`pthread_setname_np`:

```cpp
pthread_setname_np(pthread_self(), "thread_name");
```

例子：

```cpp
#include <iostream>
#include <pthread.h>

int main() {
	size_t n = 50000;
	size_t sum = 0;
	for (size_t i = 0; i < n; ++i) {
		for (size_t j = 0; j < n; ++j) {
			sum += i * j;
		}
	}
	std::cout << sum << std::endl;
	pthread_setname_np(pthread_self(), "thread_name");

	sum = 0;
	for (size_t i = 0; i < n; ++i) {
		for (size_t j = 0; j < n; ++j) {
			sum += i * j;
		}
	}
	std::cout << sum << std::endl;

	return 0;
}
```

用`top`可以看到运行到一半线程的名字会变成`thread_name`。

## 让template function接受const lvalue reference

这样是不行的：

```cpp
#include <iostream>

struct A {
	A() {}
	A(const A &) = delete;
	A &operator=(const A &) = delete;
};

template <typename T>
void func(T a) {}

int main() {
	A a;
	const A &aa = a;
	func(aa);

	return 0;
}
```

`T`会deduce成`A`，然后报错：

```text
forward.cpp: In function ‘int main()’:
forward.cpp:15:13: 错误：使用了被删除的函数‘A::A(const A&)’
   15 |         func(aa);
      |         ~~~~^~~~
forward.cpp:5:9: 附注：在此声明    5 |         A(const A &) = delete;
      |         ^
forward.cpp:10:13: 附注：  初始化‘void func(T) [with T = A]’的实参 1
   10 | void func(T a) {}
      |           ~~^
```

可以把template function的参数类型定义成forwarding reference `T &&`:

```cpp
#include <iostream>

struct A {
	A() {}
	A(const A &) = delete;
	A &operator=(const A &) = delete;
};

template <typename T>
void func(T &&a) {}

int main() {
	A a;
	const A &aa = a;
	func(aa);

	return 0;
}
```

它似乎是基于这样的规则：

```text
T & && = T &
T && & = T &
T && && = T &&
```

当把`const A &`传进去时，由于`const A & && = const A &`，所以`T`被deduce成了`const A &`。当把`A &&`传进去时，由于`A && && = A &&`，所以`T`被deduce成了`A &&`。

关于forwarding reference（也有人叫它universal reference），详见：<https://isocpp.org/blog/2012/11/universal-references-in-c11-scott-meyers>

## 其他

- {% post_link C++/'C++获取日期时间戳' %}

- {% post_link C++/'C++内存占用分析' %}

## 已知的问题

## 不能O(1)地实现`std::vector<char>`和`std::string`的互相转换。

## 无法把成员变量的初始化推迟到constructor body

<https://stackoverflow.com/questions/2464296/is-it-possible-to-defer-member-initialization-to-the-constructor-body>
