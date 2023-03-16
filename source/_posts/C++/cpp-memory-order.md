---
title: C++ memory order
date: 2023-03-16 15:40:17
tags:
---

现代处理器是乱序执行的。虽然现代处理器通常而言保证了一个线程可以认为自己是串行执行的，也就是说前面的指令一定不会受到当前线程的后面的指令的影响，而且后面的指令一定可以看到前面的指令的执行结果，但是乱序执行仍然会导致另一个线程观察到当前线程的指令在乱序执行。

打个比方，比如有下面两个线程：

```text
// x = 0, y = 0

// Thread A
x = 1
y = x + 1

// Thread B
by = y
bx = x
```

线程A中，`y=x+1`一定可以看到`x=1`的执行结果，所以`y`最终一定等于`2`。但是线程B中，却可能先观察到`y`被赋值为2，再观察到`x`被赋值为1，因此`by`和`bx`的值可能会被分别赋值为`2`和`0`。

C++中可以通过指定memory order解决这类问题。标准库中提供的memory order：

```cpp
std::memory_order_relaxed
std::memory_order_consume
std::memory_order_acquire
std::memory_order_release
std::memory_order_acq_rel
std::memory_order_seq_cst
```

文档：<https://en.cppreference.com/w/cpp/atomic/memory_order>

### `std::memory_order_relaxed`

相当于没有屏障。

### `std::memory_order_release`

如果一个store被标记为`std::memory_order_release`，那么当前线程中的任何read和write都不会被reorder到这个store后面。

这样，别的线程看到这个store时，也能看到它前面的所有read和write。

上面的例子中，只需要让y的赋值采用`std::memory_order_release`，即可保证其他线程一定是先看到`x=1`，再看到`y=2`。

### `std::memory_order_consume`

如果一个load被标记为`std::memory_order_consume`，那么当前线程中对同一块内存的read和write不会被reorder到这个load前面。

`std::memory_order_consume`和`std::memory_order_release`配合使用。通常用法：

```cpp
// Thread A
A中的准备工作
x.store(值, std::memory_order_release)

// Thread B
y = x.load(std::memory_order_consume)
B中的后续工作
```

这样，假使`B中的后续工作`中有修改`x`的操作，他们也不会被reorder到`x.load`前面，因此不会影响到`A中的准备工作`。

### `std::memory_order_acquire`

如果一个load被标记为`std::memory_order_acquire`，那么当前线程中的任何read和write都不会被reorder到这个load前面。

`std::memory_order_acquire`和`std::memory_order_release`配合使用。通常用法：

```cpp
// Thread A
A中的准备工作
x.store(值, std::memory_order_release)

// Thread B
y = x.load(std::memory_order_acquire)
B中的后续工作
```

这样，`B中的后续工作`不会被reorder到`x.load`前面，因此不会影响到`A中的准备工作`。

### `std::memory_order_acq_rel`

用于read-modify-write操作，表示它既是acquire也是release，即当前线程的任何read和write都既不会被reorder到它的前面也不会reorder到它的后面。相当于一个`mfence`？

### `std::memory_order_seq_cst`

`seq_cst`表示SEQuentially ConSisTent ordering。`std::atomic`的`load`、`store`、`compare_exchange_weak`、`compare_exchange_strong`的memory order默认是`std::memory_order_seq_cst`。

[文档](https://en.cppreference.com/w/cpp/atomic/memory_order)里是这么说的：

如果load被标记为`std::memory_order_seq_cst`，表示它是一个acquire操作。

如果store被标记为`std::memory_order_seq_cst`，表示它是一个release操作。

如果read-modify-write被标记为`std::memory_order_seq_cst`，表示它既是acquire操作又是release操作。

此外，`seq_cst`还额外保证了所有thread看到的修改的顺序都是一样的。根据这里：[How do memory_order_seq_cst and memory_order_acq_rel differ?](https://stackoverflow.com/a/58043923/13688160)，`seq_cst`会清空store buffer，从而使得后续的read和write在当前的store在全局可见之后才会执行。而`acq_rel`并不要求清空store buffer，只需要前面的操作在当前操作完成前完成，后面的操作在当前操作完成后完成即可。

文档（没看懂）：<https://en.cppreference.com/w/cpp/atomic/memory_order#Sequentially-consistent_ordering>

### 一些实验

#### relaxed无法阻止reorder

```cpp
#include <iostream>
#include <thread>
#include <atomic>

std::atomic<int> a(0), b(0);
int val_a, val_b;
void A() {
	a.store(1, std::memory_order_relaxed);
	val_b = b.load(std::memory_order_relaxed);
}
void B() {
	b.store(1, std::memory_order_relaxed);
	val_a = a.load(std::memory_order_relaxed);
}
int main() {
	do {
		a.store(0);
		b.store(0);
		std::thread tA(A);
		std::thread tB(B);
		tA.join();
		tB.join();
	} while (val_a != 0 || val_b != 0);
	std::cout << "a == 0 && b == 0!\n";
	return 0;
}
```

可以产生`a == 0 && b == 0!`的结果，说明`A`和`B`中至少有一个的`load`被reorder到`store`前面去了。

#### acquire load可以reorder到release store前面

```cpp
#include <iostream>
#include <thread>
#include <atomic>

std::atomic<int> a(0), b(0);
int val_a, val_b;
void A() {
	a.store(1, std::memory_order_release);
	val_b = b.load(std::memory_order_acquire);
}
void B() {
	b.store(1, std::memory_order_release);
	val_a = a.load(std::memory_order_acquire);
}
int main() {
	do {
		a.store(0);
		b.store(0);
		std::thread tA(A);
		std::thread tB(B);
		tA.join();
		tB.join();
	} while (val_a != 0 || val_b != 0);
	std::cout << "a == 0 && b == 0!\n";
	return 0;
}
```

可以产生`a == 0 && b == 0!`的结果，说明`A`和`B`中至少有一个的`load`被reorder到`store`前面去了。

#### load不能被reorder到release store后面

```cpp
#include <iostream>
#include <thread>
#include <atomic>

std::atomic<int> a(0), b(0);
int val_a, val_b;
void A() {
	val_b = b.load(std::memory_order_relaxed);
	a.store(1, std::memory_order_release);
}
void B() {
	val_a = a.load(std::memory_order_relaxed);
	b.store(1, std::memory_order_release);
}
int main() {
	do {
		a.store(0);
		b.store(0);
		std::thread tA(A);
		std::thread tB(B);
		tA.join();
		tB.join();
	} while (val_a != 1 || val_b != 1);
	std::cout << "a == 1 && b == 1!\n";
	return 0;
}
```

无法产生`a == 1 && b == 1!`的结果。

#### store不能被reorder到acquire load前面

```cpp
#include <iostream>
#include <thread>
#include <atomic>

std::atomic<int> a(0), b(0);
int val_a, val_b;
void A() {
	val_b = b.load(std::memory_order_acquire);
	a.store(1, std::memory_order_relaxed);
}
void B() {
	val_a = a.load(std::memory_order_acquire);
	b.store(1, std::memory_order_relaxed);
}
int main() {
	do {
		a.store(0);
		b.store(0);
		std::thread tA(A);
		std::thread tB(B);
		tA.join();
		tB.join();
	} while (val_a != 1 || val_b != 1);
	std::cout << "a == 1 && b == 1!\n";
	return 0;
}
```

无法产生`a == 1 && b == 1!`的结果。

#### 默认使用的`seq_cst`可以防止reorder

```cpp
#include <iostream>
#include <thread>
#include <atomic>

std::atomic<int> a(0), b(0);
int val_a, val_b;
void A() {
	a.store(1);
	val_b = b.load();
}
void B() {
	b.store(1);
	val_a = a.load();
}
int main() {
	do {
		a.store(0);
		b.store(0);
		std::thread tA(A);
		std::thread tB(B);
		tA.join();
		tB.join();
	} while (val_a != 0 || val_b != 0);
	std::cout << "a == 0 && b == 0!\n";
	return 0;
}
```

使用默认的`std::memory_order_seq_cst`无法产生`a == 0 && b == 0!`的结果。
