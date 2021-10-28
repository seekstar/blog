---
title: C++11 终止一个thread对象表示的线程
date: 2019-12-04 16:32:11
---

参考链接：
www.bo-yang.net/2017/11/19/cpp-kill-detached-thread

“terminate 1 thread + forcefully (target thread doesn’t cooperate) + pure C++11 = No way”.
~~233333~~

可以用pthread.h里的pthread_cancel来强行杀死某一线程。
注意thread对象的析构函数并不会把线程杀死。

code:
```cpp
#include <iostream>
#include <thread>
#include <chrono>
#include <pthread.h>

using namespace std;

void foo() {
	size_t x = 0;
	while (1) {
		cout << ++x << endl;
		this_thread::sleep_for(chrono::milliseconds(100));
	}
}

int main() {
	std::cerr << "1、先杀死再join\n";
	{
		thread t(foo);
		this_thread::sleep_for(chrono::seconds(1));
		cout << "t.joinable() = " << t.joinable() << endl;
		pthread_cancel(t.native_handle());
		cout << "after cancelling, t.joinable() = " << t.joinable() << endl;
		t.join();
	}
	cout << "The thread is destructed\n\n";
	this_thread::sleep_for(chrono::seconds(1));

	std::cerr << "2、先detach再杀死\n";
	{
		thread t(foo);
		pthread_t id = t.native_handle();
		t.detach();
		cout << "detached\n";
		this_thread::sleep_for(chrono::seconds(1));
		cout << "t.joinable() = " << t.joinable() << endl;
		pthread_cancel(id);
	}
	cout << "The thread is destructed\n\n";
	this_thread::sleep_for(chrono::seconds(1));

	std::cerr << "3、thread对象的析构函数不会杀死线程\n";
	{
		thread t(foo);
		t.detach();
		this_thread::sleep_for(chrono::seconds(1));
	}
	this_thread::sleep_for(chrono::seconds(1));

	return 0;
}
```

output:
```
1、先杀死再join
1
2
3
4
5
6
7
8
9
10
t.joinable() = 1
after cancelling, t.joinable() = 1
The thread is destructed

2、先detach再杀死
detached
1
2
3
4
5
6
7
8
9
10
t.joinable() = 0
The thread is destructed

3、thread对象的析构函数不会杀死线程
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
```

1. [一个thread对象在析构前必须要detach或者join](https://www.cnblogs.com/ranson7zop/p/8028799.html)，不然会报错：```terminate called without an active exception```

所以如果没有detach，cancel完了要join一下。
而且自然销毁前必须detach。

2. detach之后native_handle返回的值就不对了，所以要在detach之前把这个值保存起来。
