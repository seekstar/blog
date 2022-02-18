---
title: 'luogu P4332 [SHOI2014]三叉神经树 LCT'
date: 2021-11-18 21:03:32
tags:
---

将节点的值定义为其输入中1的个数。观察发现，每次修改的都是一条链上的值：如果是将某个节点的值从1改成0，那么就是要将这个节点到其祖先中离该节点最近的值非2的节点的值全部减一，如果是将某个节点的值从0改成1，那么就是要将这个节点到其祖先中离该节点最近的值非1的节点的值全部加1。

所以维护splay表示的链中最后一个值非1和值非2的节点的位置即可。修改节点x的值的时候，先`access(x)`，然后将最后一个值非1（或者非2）的节点（记为y）splay到根，然后对y节点做单点修改，对y的右子树做区间加。有一个特殊情况，就是找不到这样的节点y，这说明从x一直到根都是1（或者2），这时直接对整条链做区间加就好了，而且此时根的输出必然会翻转。

注意，这题中，LCT并不需要做换根操作。

这题告诉我们，LCT要灵活应用，不要只记得`link`和`cut`以及区间操作之类的标准化的用法。灵活运用`splay`和`access`更强大。

代码：

```C++
#include <iostream>
#include <cstring>
#include <cassert>
#include <cmath>

using namespace std;

#define MAXN 500011

struct LCT {
	int c[MAXN][2], fa[MAXN], sta[MAXN];
	// val[i] is the number of 1 in the input of node i.
	// not_1[i] is the last node whose value is not 1 in the current subtree.
	int val[MAXN], not_1[MAXN], not_2[MAXN], lazy_add[MAXN];

	inline int& ls(int rt) {
		return c[rt][0];
	}
	inline int& rs(int rt) {
		return c[rt][1];
	}
	inline bool not_splay_rt(int x) {
		return ls(fa[x]) == x || rs(fa[x]) == x;
	}
	inline int side(int x) {
		return x == rs(fa[x]);
	}
	void Init() {
		// Initially every node is a tree by itself.
		// memset all to 0.
	}
	inline void push_add(int x, unsigned int c) {
		swap(not_1[x], not_2[x]);
		val[x] += c;
		lazy_add[x] += c;
	}
	inline void pushdown(int x) {
		if (lazy_add[x]) {
			if (ls(x))
				push_add(ls(x), lazy_add[x]);
			if (rs(x))
				push_add(rs(x), lazy_add[x]);
			lazy_add[x] = 0;
		}
	}
	inline void pushup(int x) {
		not_1[x] = not_1[rs(x)] ? not_1[rs(x)] :
			(val[x] != 1 ? x : not_1[ls(x)]);
		not_2[x] = not_2[rs(x)] ? not_2[rs(x)] :
			(val[x] != 2 ? x : not_2[ls(x)]);
	}
	// s[x] is not updated
	void __rotate_up(int x) {
		int y = fa[x], z = fa[y], side_x = side(x), w = c[x][side_x ^ 1];
		fa[x] = z;
		if (not_splay_rt(y))
			c[z][side(y)] = x;
		if (w)
			fa[w] = y;
		c[y][side_x] = w;
		fa[y] = x;
		c[x][side_x ^ 1] = y;
		pushup(y);
	}
	// s[x] is not updated
	void __splay(int x) {
		int y = x, top = 0;
		while(1) {
			sta[++top] = y;
			if (!not_splay_rt(y))
				break;
			y = fa[y];
		}
		int to = fa[y];
		while (top)
			pushdown(sta[top--]);
		while (fa[x] != to) {
			int y = fa[x];
			if (fa[y] != to)
				__rotate_up(side(x) == side(y) ? y : x);
			__rotate_up(x);
		}
	}
	inline void splay(int x) {
		__splay(x);
		pushup(x);
	}
	void access(int x) {
		int ori_x = x;
		for (int w = 0; x; w = x, x = fa[x]) {
			__splay(x);
			rs(x) = w;
			pushup(x);
		}
		splay(ori_x);
	}
	inline void link_new(int rt, int x) {
		// If simply fa[x] = y, the complexity might be wrong.
		access(rt);
		access(x);
		fa[x] = rt;
		ls(rt) = x;
		pushup(rt); // Might be unnecessary
	}
};

int main() {
	static LCT lct;
	int n, q;
	static int fa[MAXN * 3], refcnt[MAXN], sta[MAXN];
	static bool val[MAXN * 3];
	int top = 0;

	scanf("%d", &n);
	for (int i = 1; i <= n; ++i) {
		int x1, x2, x3;
		scanf("%d%d%d", &x1, &x2, &x3);
		fa[x1] = fa[x2] = fa[x3] = i;
		refcnt[i] = 3;
	}
	for (int i = n + 1; i <= 3 * n + 1; ++i) {
		int v;
		scanf("%d", &v);
		val[i] = v;
		if (v)
			++lct.val[fa[i]];
		if (--refcnt[fa[i]] == 0) {
			sta[++top] = fa[i];
		}
	}
	while (top) {
		int i = sta[top--];
		if (lct.val[i] > 1) {
			++lct.val[fa[i]];
		}
		if (fa[i])
			lct.link_new(i, fa[i]);
		if (--refcnt[fa[i]] == 0) {
			sta[++top] = fa[i];
		}
	}
	int rt = sta[1];
	bool rt_val = (lct.val[rt] > 1);
	scanf("%d", &q);
	while (q--) {
		int i;
		scanf("%d", &i);
		int x = fa[i];
		lct.access(x);
		int add = (val[i] == 0 ? 1 : -1);
		val[i] ^= 1;
		int y = (add > 0 ? lct.not_1 : lct.not_2)[x];
		if (y == 0) {
			lct.push_add(x, add);
			rt_val ^= 1;
		} else {
			lct.splay(y);
			lct.val[y] += add;
			lct.push_add(lct.rs(y), add);
			lct.pushup(y);
		}
		printf("%d\n", rt_val);
	}

	return 0;
}
```
