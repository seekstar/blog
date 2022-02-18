---
title: 把boost::bind的返回值插入到std::unordered_map中
date: 2020-05-03 12:56:26
tags:
---

- 只能以insert的形式插入，不能以`[]`的形式插入。原因不明。
- 不同的类里的成员函数不能插入同一个unordered_map中。
- 同一个类里的相同参数的成员函数可以插入同一个unordered_map中。

```cpp
#include <iostream>
#include <unordered_map>

#include <boost/bind.hpp>

using namespace std;

struct A {
	void print(int x) {
		cout << x << endl;
	}
	void print2(int x) {
		cout << "2 " << x << endl;
	}
};
struct B {
	void print(long long x) {
		cout << x << endl;
	}
};
struct C {
	void print(int x) {
		cout << x << endl;
	}
	int sth;
};

int main() {
	unordered_map<int, decltype(boost::bind(&A::print, A(), int()))> ma;

	A a;
	int x = 2333;
	auto f = boost::bind(&A::print, a, x);
	//ma[1] = f;
	ma.insert(make_pair(2, f));
	x = 0;
	auto it = ma.find(2);
	if (it != ma.end()) {
		it->second();
	} else {
		cout << "not found\n";
	}

	long long llx = 23333;
	B b;
	auto g = boost::bind(&B::print, b, llx);
	llx = 0;
	//ma.insert(make_pair(3, g));

	x = 2333;
	C c;
	auto h = boost::bind(&C::print, c, x);
	x = 0;
	//ma.insert(make_pair(4, h));

	x = 23332;
	auto f2 = boost::bind(&A::print2, a, x);
	ma.insert(make_pair(5, f2));
	ma.find(5)->second();

	return 0;
}
```
```
2333
2 23332
```
