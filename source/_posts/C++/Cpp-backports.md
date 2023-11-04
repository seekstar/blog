---
title: C++ backports
date: 2023-07-17 16:52:29
tags:
---

## `std::optional` (since C++17)

```cpp
#include <iostream>

struct in_place_t {};
inline constexpr in_place_t in_place{};

template <typename T>
class optional {
public:
	optional() : has_value_(false) {}
	optional(T&& x) : has_value_(true), x_(std::move(x)) {}
	optional(
		in_place_t, Args&&... args
	) : has_value_(true), x_(std::forward<Args>(args)...) {}
	optional<T>& operator=(T&& x) {
		if (has_value_)
			x_.~T();
		has_value_ = true;
		x_ = std::move(x);
		return *this;
	}
	optional(const optional<T>& rhs) : has_value_(rhs.has_value_) {
		if (has_value_) {
			x_ = rhs.x_;
		}
	}
	optional<T>& operator=(const optional<T>& rhs) {
		this->~optional();
		has_value_ = rhs.has_value_;
		if (has_value_) {
			x_ = rhs.x_;
		}
		return *this;
	}
	optional(optional<T>&& rhs) : has_value_(rhs.has_value_) {
		if (has_value_) {
			x_ = std::move(rhs.x_);
			rhs.has_value_ = false;
		}
	}
	optional<T>& operator=(optional<T>&& rhs) {
		this->~optional();
		has_value_ = rhs.has_value_;
		if (has_value_) {
			x_ = std::move(rhs.x_);
			rhs.has_value_ = false;
		}
		return *this;
	}
	~optional() {
		if (has_value_) {
			x_.~T();
		}
	}
	bool has_value() const { return has_value_; }
	T &value() { return x_; }
	const T &value() const { return x_; }
	void reset() {
		if (has_value_) {
			x_.~T();
			has_value_ = false;
		}
	}


private:
	bool has_value_;
	union {
		T x_;
	};
};
// https://stackoverflow.com/a/9103132/13688160
template <typename T, typename... Args>
optional<T> make_optional(Args &&...args) {
	return optional<T>(in_place, std::forward<Args>(args)...);
}

class A {
public:
	A(int x) : x_(x) {}
	A(A& rhs) : x_(rhs.x_) {}
	A& operator=(const A& rhs) {
		x_ = rhs.x_;
		return *this;
	}
	A(A&& rhs) : x_(rhs.x_) {
		rhs.x_ = 0;
	}
	A& operator=(A&& rhs) {
		x_ = rhs.x_;
		rhs.x_ = 0;
		return *this;
	}
	~A() {
		std::cout << "~A(): " << x_ << std::endl;
	}
private:
	int x_;
};
int main() {
	std::cout << "1\n";
	{
		optional<A> x;
	}
	std::cout << "2\n";
	{
		make_optional<A>(233);
	}
	std::cout << "3\n";
	{
		optional<A> x;
		x = A(233);
	}
	std::cout << "4\n";
	{
		auto x = make_optional<A>(233);
		x = A(466);
	}
	std::cout << "5\n";
	{
		auto x = make_optional<A>(233);
		auto y = make_optional<A>(466);
		x = y;
	}
	std::cout << "6\n";
	{
		auto x = make_optional<A>(233);
		auto y = make_optional<A>(466);
		x = std::move(y);
	}
	std::cout << "7\n";
	{
		optional<int> x;
		std::cout << x.has_value() << std::endl;
		x = 233;
		std::cout << x.has_value() << ' ' << x.value() << std::endl;
		x.value() = 466;
		std::cout << x.has_value() << ' ' << x.value() << std::endl;
	}
	std::cout << "8\n";
	{
		auto x = make_optional<A>(233);
		x.reset();
	}
	return 0;
}
```

```text
1
2
~A(): 0
~A(): 233
3
~A(): 0
~A(): 233
4
~A(): 233
~A(): 0
~A(): 466
5
~A(): 233
~A(): 466
~A(): 466
6
~A(): 233
~A(): 466
7
0
1 233
1 466
8
~A(): 233
```
