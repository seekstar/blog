---
title: pb_ds学习笔记
date: 2020-03-30 22:39:47
---

文档：[Policy-Based Data Structures](https://gcc.gnu.org/onlinedocs/libstdc++/ext/pb_ds/)

相关文章：[pb_ds库实现支持多个相同的值的名次树](https://seekstar.github.io/2019/06/30/pb-ds%E5%BA%93%E5%AE%9E%E7%8E%B0%E6%94%AF%E6%8C%81%E5%A4%9A%E4%B8%AA%E7%9B%B8%E5%90%8C%E7%9A%84%E5%80%BC%E7%9A%84%E5%90%8D%E6%AC%A1%E6%A0%91/)

建议使用
```cpp
using namespace __gnu_pbds;
```

# tree
参考：<https://www.cnblogs.com/keshuqi/p/6257895.html>
文档：
[tree](https://gcc.gnu.org/onlinedocs/gcc-4.7.1/libstdc++/api/a00378.html)
[tree_order_statistics_node_update](https://gcc.gnu.org/onlinedocs/gcc-4.7.1/libstdc++/api/a00379.html)

## 头文件
```cpp
#include <ext/pb_ds/tree_policy.hpp>
#include <ext/pb_ds/assoc_container.hpp>
```
## 原型
```cpp
template<typename Key, typename Mapped, typename Cmp_Fn = std::less<Key>, typename Tag = rb_tree_tag, template< typename Node_CItr, typename Node_Itr, typename Cmp_Fn_, typename _Alloc_ > class Node_Update = null_node_update, typename _Alloc = std::allocator<char>>
class __gnu_pbds::tree< Key, Mapped, Cmp_Fn, Tag, Node_Update, _Alloc >
```
## 说明
- Mapped
被映射的东西。如果没有则为null_type
- Tag
常用rb_tree_tag, splay_tree_tag
- Node_Update
常用`tree_order_statistics_node_update`。
它提供了以下成员函数
1. `size_type order_of_key(key_const_reference key) const`
返回比`key`小的元素的个数
2. `iterator 	find_by_order (size_type order)`以及其const版本
返回第`order`大的元素的迭代器
## 用法举例
- 一颗名次红黑树
```cpp
tree<int, null_type, less<int>, rb_tree_tag, tree_order_statistics_node_update> t;
```
## 常用成员函数
- clear
- insert
- erase
- lower_bound(Key key)
返回最小的 >= key 的元素的迭代器
- upper_bound
返回最小的 > key 的元素的迭代器
- `a.join(tree& b)`
b并入a，前提是两棵树的key的取值范围不相交。b会被清空。
- `a.split(Key v, tree& b)`
key小于等于v的元素属于a，其余的属于b。b原有的元素会被清空。

# 堆
文档：<https://gcc.gnu.org/onlinedocs/gcc-4.7.0/libstdc++/api/a00356.html>

具体用法和普通优先队列差不多。
## 头文件
```cpp
#include<ext/pb_ds/priority_queue.hpp>
```

## 声明
```cpp
template<typename _Tv, typename Cmp_Fn = std::less<_Tv>, typename Tag = pairing_heap_tag, typename _Alloc = std::allocator<char>>
class __gnu_pbds::priority_queue< _Tv, Cmp_Fn, Tag, _Alloc >
```
使用时必须带上`__gnu_pbds::`，因为它与`std::priority_queue`重名了。

## 迭代器
它的迭代器叫做`point_iterator`。例如
```cpp
__gnu_pbds::priority_queue<int>::point_iterator it;
```
## Tag
- pairing_heap_tag
默认的，最快
- binary_heap_tag
- binomial_heap_tag
- rc_binomial_heap_tag
- thin_heap_tag

## 常用成员函数
同`std::priority_queue`的成员函数有
- top
- size
- empty
- clear
- pop

不同的有
- push
返回迭代器
- `join(priority_queue &other)`
合并两个堆,other会被清空
- `split(Pred prd,priority_queue &other)`
分离出两个堆。其中Pred是predicate（谓词）的缩写，用于判断哪些元素被放入other中。如果prd(key)返回true，key被放入other中。

例如把a中小于３的数放入b中
```cpp
template<typename T, T val>
struct less_than {
	bool operator () (T x) {
		return x < val;
	}
};

a.split(less_than<int, 3>(), b);
```
 - `modify(point_iterator it,const key)`
 修改迭代器`it`指向的值为`key`。
