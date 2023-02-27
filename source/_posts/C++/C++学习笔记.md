---
title: C++学习笔记
date: 2020-04-03 23:33:34
---

## string和int相互转化

参考：<https://blog.csdn.net/lxj434368832/article/details/78874108>

string -> int

```cpp
string str("123");
int ret = atoi(str.c_str());
```

int -> string
C++11中可以用to_string

```cpp
int x = 123;
string str = to_string(x);
```

## 输出字符型指针指向的地址

参考：<https://www.cnblogs.com/wxxweb/archive/2011/05/20/2052256.html>

```cpp
cout << (const void*)char_pointer << endl;
```

## 多线程

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
