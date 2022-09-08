---
title: C++调用Rust
date: 2022-09-02 13:36:46
tags:
---

相关：{% post_link Rust/'C语言调用Rust' %}

## 场景

在C++中有一个类想用Rust的`std::collections::BinaryHeap`维护：

```cpp
class A {
public:
	A(const char* data, size_t size) : data_(data), size_(size) {}
	const char* data() const { return data_; }
	size_t size() const { return size_; }
	bool operator < (const A& rhs) const {
		if (size() < rhs.size()) {
			return true;
		}
		if (size() > rhs.size()) {
			return false;
		}
		return memcmp(data(), rhs.data(), size()) < 0;
	}
private:
	const char* data_;
	size_t size_;
};
```

并且提供这些接口：

```cpp
extern void* Create();
extern void Push(void* heap, A a);
extern A Pop(void* heap);
extern void Destroy(void* heap);
```

## 思路

Rust只能提供C语言的接口，结构体也只认C语言的结构体。

因此首先专门另写一份C++代码，调用Rust提供的C接口实现所需的C++接口，并且将C++提供的操作封装成C语言接口给Rust调用。

## 代码

### 结构

```text
├── heap
│   ├── Cargo.lock
│   ├── Cargo.toml
│   ├── cpp
│   │   ├── cpp_to_rust.cpp
│   │   ├── c_struct.h
│   │   └── rust_to_cpp.cpp
│   ├── include
│   │   └── heap.h
│   ├── Makefile
│   ├── src
│   │   └── lib.rs
│   └── target
├── test.cpp
└── test.h
```

### C++使用端

`test.h`:

```cpp
#ifndef TEST_H_
#define TEST_H_

#include <cstddef>
#include <cstring>

class A {
public:
	A(const char* data, size_t size) : data_(data), size_(size) {}
	const char* data() const { return data_; }
	size_t size() const { return size_; }
	bool operator < (const A& rhs) const {
		if (size() < rhs.size()) {
			return true;
		}
		if (size() > rhs.size()) {
			return false;
		}
		return memcmp(data(), rhs.data(), size()) < 0;
	}
private:
	const char* data_;
	size_t size_;
};

#endif // TEST_H_
```

`test.cpp`:

```cpp
#include <cstdio>
#include <cstring>

#include "test.h"
#include "heap.h"

using namespace std;

int main() {
	void* heap = Create();
	Push(heap, A("233", 3));
	Push(heap, A("2333", 4));
	Push(heap, A("332", 3));
	puts(Pop(heap).data());
	puts(Pop(heap).data());
	puts(Pop(heap).data());
	Destroy(heap);

	return 0;
}
```

### 新建Rust项目

```shell
cargo new heap --lib
```

在`heap/Cargo.toml`中加入：

```toml
[lib]
crate-type = ["staticlib"]
```

`heap/src/lib.rs`:

```rust
use std::collections::BinaryHeap;
use std::cmp::Ordering;
use std::os::raw::c_char;

extern "C" {
    fn compare(a: *const C_A, b: *const C_A) -> bool;
}

#[repr(C)]
#[derive(Eq)]
pub struct C_A {
    data: *const c_char,
    size: usize,
}

impl Ord for C_A {
    fn cmp(&self, rhs: &C_A) -> Ordering {
        unsafe {
            let a: *const C_A = self;
            let b: *const C_A = rhs;
            if compare(a, b) {
                Ordering::Less
            } else if compare(b, a) {
                Ordering::Greater
            } else {
                Ordering::Equal
            }
        }
    }
}

impl PartialOrd for C_A {
    fn partial_cmp(&self, rhs: &C_A) -> Option<Ordering> {
        Some(self.cmp(rhs))
    }
}

impl PartialEq for C_A {
    fn eq(&self, rhs: &C_A) -> bool {
        self.cmp(rhs) == Ordering::Equal
    }
}

#[no_mangle]
pub extern "C" fn __rust_create() -> *mut BinaryHeap<C_A> {
    Box::into_raw(Box::new(BinaryHeap::<C_A>::new()))
}

#[no_mangle]
pub extern "C" fn __rust_push(heap: *mut BinaryHeap<C_A>, a: C_A) {
    let heap = unsafe { &mut *heap };
    heap.push(a);
}

#[no_mangle]
pub extern "C" fn __rust_pop(heap: *mut BinaryHeap<C_A>) -> C_A {
    let heap = unsafe { &mut *heap };
    // Use unwrap_unchecked to avoid panic. C++ does not know how to panic anyway.
    unsafe { heap.pop().unwrap_unchecked() }
}

#[no_mangle]
pub extern "C" fn __rust_destroy(heap: *mut BinaryHeap<C_A>) {
    unsafe { Box::from_raw(heap) };
}
```

`#[repr(C)]`: repr的意思是representation。`repr(C)`表示用C语言的方式来组织这个结构体，这样这个结构体就可以在C语言和Rust之间传递了。

参考：<https://stackoverflow.com/questions/24105186/can-i-call-c-or-c-functions-from-rust-code>

### C语言结构体

Rust只兼容C语言结构体，所以要先把C++结构体变成C语言结构体，才能传给Rust用。同样，Rust传出来的结构体也只能是C语言结构体，要转成对应的C++结构体。

`heap/cpp/c_struct.h`:

```cpp
#ifndef C_STRUCT_H_
#define c_STRUCT_H_

#include <cstddef>

extern "C" {
	struct CA {
		const char* data;
		size_t size;
	};
}

#endif // C_STRUCT_H_
```

这里的`struct CA`就是Rust里的`struct C_A`。这里特定用了不同的名字，说明两者名字不一定要相同。

参考：<https://stackoverflow.com/questions/62126501/how-to-pass-a-c-struct-to-rust>

### 将C++操作封装成C语言接口

`BinaryHeap`需要用到比较操作。但是`A`的比较操作是`operator <`，Rust显然不能直接用。因此需要将这个操作封装成C语言结构，Rust才能用。

`heap/cpp/cpp_to_rust.cpp`:

```cpp
#include "test.h"
#include "c_struct.h"

extern "C" {
	bool compare(const CA* ca, const CA* cb);
}

bool compare(const CA* ca, const CA* cb) {
	A a(ca->data, ca->size);
	A b(cb->data, cb->size);
	return a < b;
}
```

### 使用Rust接口实现所需的C++接口

`heap/cpp/rust_to_cpp.cpp`:

```cpp
#include "test.h"
#include "c_struct.h"

#include <cstddef>

extern "C" {
	extern void* __rust_create();
	extern void __rust_push(void* heap, CA a);
	extern CA __rust_pop(void* heap);
	extern void __rust_destroy(void* heap);
}


void* Create() {
	return __rust_create();
}

void Push(void* heap, A a) {
	struct CA ca{
			.data = a.data(),
			.size = a.size(),
	};
	__rust_push(heap, ca);
}

A Pop(void* heap) {
	CA ca = __rust_pop(heap);
	return A(ca.data, ca.size);
}

void Destroy(void* heap) {
	__rust_destroy(heap);
}
```

### 将实现的C++接口放进头文件

`include/heap.h`:

```cpp
#ifndef HEAP_H_
#define HEAP_H_

#include "test.h"

extern void* Create();
extern void Push(void* heap, A a);
extern A Pop(void* heap);
extern void Destroy(void* heap);

#endif // HEAP_H_
```

### Makefile

`heap/Makefile`:

```Makefile
ifndef INCLUDE_DIR
# 这里不能缩进。
$(error INCLUDE_DIR is undefined)
endif

target/cpp_to_rust.o: cpp/cpp_to_rust.cpp cpp/c_struct.h $(INCLUDE_DIR)/test.h
	g++ -I $(INCLUDE_DIR) cpp/cpp_to_rust.cpp -c -o $@

target/rust_to_cpp.o: cpp/rust_to_cpp.cpp cpp/c_struct.h $(INCLUDE_DIR)/test.h
	g++ -I $(INCLUDE_DIR) cpp/rust_to_cpp.cpp -c -o $@

target/debug/libheap.a: $(shell find src -type f) Cargo.toml Cargo.lock
	cargo build

target/debug/libheap.o: target/cpp_to_rust.o target/rust_to_cpp.o target/debug/libheap.a
	ld -r -o $@ --whole-archive target/rust_to_cpp.o --no-whole-archive target/cpp_to_rust.o target/debug/libheap.a

obj_debug: target/debug/libheap.o

target/debug/libheap.so: obj_debug
	gcc -shared $^ -ldl -o $@

shared_lib_debug: target/debug/libheap.so

.PHONY: debug shared_lib_debug
```

其中`ld`的`-r`表示`relocatable`。按照我的理解，由于要将多个`.o`文件合并起来，所以不可避免地要进行`relocation`。

`--whole-archive`：将后面的文件里的所有符号都加入到目标文件中。`--no-whole-archive`是取消前面的`--whole-archive`的影响，使得后面的文件里只有用到了的符号才加入到目标文件。这里`rust_to_cpp.o`里存储了需要给使用端用的C++接口，因此里面的符号应该全部加入到目标文件中。而其他的选择性加入即可。

然后`make obj_debug INCLUDE_DIR=..`即可编译出`target/debug/libheap.o`，里面有我们需要的C++接口。`make shared_lib_debug INCLUDE_DIR=..`即可编译出动态库`target/debug/libheap.so`。

参考：

<https://stackoverflow.com/questions/3821916/how-to-merge-two-ar-static-libraries-into-one>

<https://stackoverflow.com/questions/29391965/what-is-partial-linking-in-gnu-linker>

<https://stackoverflow.com/questions/14289513/makefile-rule-that-depends-on-all-files-under-a-directory-including-within-subd>

<https://stackoverflow.com/questions/4728810/how-to-ensure-makefile-variable-is-set-as-a-prerequisite>

`缩进后的语句一律视为编译目标的一部分，作为shell语句解释。`：<https://anclark.github.io/2021/02/09/Programming_Tips/Makefile_%E8%B8%A9%E5%9D%91%E8%AE%B0/>

<https://stackoverflow.com/questions/2826029/passing-additional-variables-from-command-line-to-make>

`-ldl`: [编译错误undefined reference to `dlsym'](https://blog.csdn.net/shareyao/article/details/5362642)。不过这里好像不加`-ldl`也不会报这个错误。

## 使用

用obj文件：

```shell
gcc -I heap/include/ -I. heap/target/debug/libheap.o test.cpp -o test
./test
```

用动态库：

```shell
gcc -I heap/include -I. -L heap/target/debug/ -lheap test.cpp -o test
LD_LIBRARY_PATH=heap/target/debug/ ./test
```

输出：

```text
2333
332
233
```

## 注意事项

由于Rust编译出来的目标文件里会自带很多符号，因此本博客提供的方法无法实现C++代码调用多个Rust工程提供的接口，需要将所有Rust接口的实现都塞进一个Rust工程。暂时不清楚解决方案。
