---
title: poj 3667 STL写法（非线段树写法）
date: 2019-07-12 17:08:53
---

题目链接：https://vjudge.net/problem/POJ-3667

题目大意：
已知数组长度为n (n <= 50000)，一开始全部为0。有m (m <= 50000)个操作，有两种操作
1. 给出d，找到最小的r，使得区间[r, r + d - 1]内所有数组元素都为0。若能找到，则输出r，并且把该区间元素都变成1。若找不到，则输出0。
2. 给出x和d，将区间[x, x+d-1]中所有元素清0。

思路：
这有点像内存分配，下面我们套用内存模型。
我们保存每个空闲的内存块的长度和首地址，每次进行操作1时找到长度大于等于d且首地址尽量小的内存块，然后占用之即可。每次进行操作2时
1. 设[start, end)为要清零的区间。
2. 找到最后一个首地址小于x的内存块，如果该内存块与[start, end)接触，那么就更新start为该内存块的首地址，end = max(end, 内存块末尾)，然后将该内存块删去。
3. 找到第一个首地址>=start的内存块。如果该内存块没有与[start, end)接触，那么进入第6步
4. end = max(end, 内存块末尾)，然后将该内存块删去。
5. 回到第3步。
6. 新建空闲内存块[start, end)

内存块种类最多时，有长度为1、2、3、4、... mx的内存块，而内存总长度为n，因此mx最大为O(sqrt(n))。
进行操作1时，我们在长度的集合中枚举大于等于d的长度，然后找到该长度下的最前面的内存块。这些内存块中最前面的内存块就是我们要的内存块。长度的集合可以用set维护，找该长度下最前面的内存块可以用set<pair<int, int> >的lower_bound，其中first为长度，second为首地址。复杂度为O(sqrt(n) * log(n))
进行操作2时，可以用map<int, se_it>的lower_bound来根据首地址找内存块。int为首地址，se_it为前面的set<pair<int, int> >的迭代器。

代码如下：
```cpp
#include <cstdio>
#include <set>
#include <map>

using namespace std;

#define DEBUG 0
#define ONLINE_JUDGE

#define MAXN 50010

set<int> lens;
int cnt[MAXN];
void Del(int x) {
	if (0 == --cnt[x]) {
		lens.erase(x);
	}
}
void Insert(int x) {
	if (cnt[x] == 0) {
		lens.insert(x);
	}
	++cnt[x];
}

typedef set<pair<int, int> >::iterator se_it;
typedef map<int, se_it>::iterator pos_it;
typedef set<int>::iterator lens_it;
int main() {
#ifndef ONLINE_JUDGE
	freopen("in.in", "r", stdin);
	freopen("out.out", "w", stdout);
#endif
	int n, m;
	set<pair<int, int> > se;	//len, start
	map<int, se_it> pos;

	scanf("%d%d", &n, &m);
	pair<se_it, bool> tmp = se.insert(make_pair(n, 1));
	pos[1] = tmp.first;
	Insert(n);
	while (m--) {
		int op;
		scanf("%d", &op);
		if (1 == op) {
			int d;
			scanf("%d", &d);
			int ans = 0x3f3f3f3f;
			se_it ans_it = se.end();
			for (lens_it len_it = lens.lower_bound(d); len_it != lens.end(); ++len_it) {
				se_it it = se.lower_bound(make_pair(*len_it, 0));
				if (it->second < ans) {
					ans = it->second;
					ans_it = it;
				}
			}
			se_it& it = ans_it;
			if (it == se.end()) {
				printf("0\n");
			} else {
				int start = it->second;
				int len = it->first;
				printf("%d\n", start);
				pos.erase(start);
				se.erase(it);
				Del(len);
				if (len > d) {
					pair<se_it, bool> tmp = se.insert(make_pair(len - d, start + d));
					pos[start + d] = tmp.first;
					Insert(len-d);
				}
			}
		} else {
			int x, d;
			scanf("%d%d", &x, &d);
			int end = x + d;
			pos_it it = pos.lower_bound(x);
			if (it != pos.begin()) {
				--it;
				int start = it->first;
				int len = it->second->first;
				if (start + len >= x) {
					x = start;
					end = max(end, start + len);
					se.erase(it->second);
					pos.erase(it);
					Del(len);
				}
			}
			while (1) {
				pos_it it = pos.lower_bound(x);
				if (it == pos.end()) break;
				int start = it->first;
				int len = it->second->first;
				if (start > end) break;
				end = max(end, start + len);
				se.erase(it->second);
				pos.erase(it);
				Del(len);
			}
			pair<se_it, bool> tmp = se.insert(make_pair(end - x, x));
			pos[x] = tmp.first;
			Insert(end - x);
		}
	}

	return 0;
}
```
