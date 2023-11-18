---
title: C++生成随机数
date: 2020-05-04 21:50:19
tags:
---

## 大段随机二进制

思路：先用`std::random_device`生成真随机数，用来初始化长周期随机数发生器`std::mt19937`，然后再用`std::mt19937`来不断生成随机数。

生成大段随机二进制的部分C++17之后可以用这些：

<https://en.cppreference.com/w/cpp/algorithm/generate>

<https://en.cppreference.com/w/cpp/algorithm/generate_n>

否则只能手写了。代码：

```cpp
#include <assert.h>
#include <random>

std::random_device rd;
typedef std::mt19937 RandEngine;
//RandEngine e(std::random_device()());
RandEngine e(rd());
//Generate long random binary result
void genrand(void *dest, size_t n) {
    typedef uint32_t res_t;
    assert(n >= sizeof(res_t) &&
        "This function is designed for generating long random binary result, please use other function");
    assert(n % sizeof(res_t) == 0);
    
    res_t *i = reinterpret_cast<res_t *>(dest);
    res_t *j = reinterpret_cast<res_t *>((uint8_t*)dest + n);
    for (; i < j; ++i) {
        *i = e();
    }
}
```

（坑点）不能这样：

```cpp
typedef RandEngine::result_type res_t;
```

因为标准库里的mt19937是用来生成32bit的伪随机数的，而`RandEngine::result_type`有可能是64bit的。

## 随机十进制字符串

```cpp
template <typename Engine>
std::string rand_digits(Engine e, size_t n) {
	std::uniform_int_distribution<char> dist(0, 9);
	std::string ret;
	ret.reserve(n);
	while (n--) {
		ret.push_back(dist(e) + '0');
	}
    return ret;
}
```

## 参考

<http://www.cplusplus.com/reference/random/mt19937/>
[What is uint_fast32_t and why should it be used instead of the regular int and uint32_t?](https://stackoverflow.com/questions/8500677/what-is-uint-fast32-t-and-why-should-it-be-used-instead-of-the-regular-int-and-u)
