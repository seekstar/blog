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
	void Seek(T x);
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

最优雅的方法是用C++20里的module。如果不能用C++20的话，可以弄一个隐藏的namespace来模拟module里没有export的部分。将要隐藏的构造函数声明为`protected`，然后在隐藏的namespace里声明一个继承这个类的子类，这样这个子类就可以访问这个隐藏的构造函数。将子类的构造函数声明为`public`，需要使用隐藏的构造函数时，调用子类的构造函数，然后将构造出来的子类转换为那个类即可。

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
