---
title: C++学习笔记
date: 2020-04-03 23:33:34
---

# string和int相互转化
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

# 输出字符型指针指向的地址
参考：<https://www.cnblogs.com/wxxweb/archive/2011/05/20/2052256.html>
```cpp
cout << (const void*)char_pointer << endl;
```

# 多线程
## 睡眠
参考：<https://www.cnblogs.com/alanlvee/p/5152936.html>
```cpp
#include<chrono>
#include<thread>
```
```cpp
//睡眠233ms
std::this_thread::sleep_for(std::chrono::milliseconds(233));
```

# 正则表达式
参考：<https://blog.csdn.net/philpanic9/article/details/88141305>
文档：<http://www.cplusplus.com/reference/regex/basic_regex/>

```cpp
#include <regex>
```
REGular EXpression

C++默认使用ECMAScript的正则表达式文法。
教程：<https://www.cnblogs.com/cycxtz/p/4804115.html>

## regex_match
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
```
1
0
0
0
0
```
## regex_search
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
```
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
## regex_replace
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
```
abc233efg233233
```
