---
title: codeforces 1184 C2 曼哈顿距离转切比雪夫距离，矩形覆盖最大点数转最大前缀
date: 2019-07-08 21:59:40
---

题意是给300000个点，点的横坐标和纵坐标范围为[-1e6, 1e6]，找一点A，使得与A的曼哈顿距离 <= r的点数最大，并输出最大点数。

观察可知，与A曼哈顿距离<=r的点构成了一个菱形。注意到菱形的边界的函数为x + y = k和x - y = k，因此想到可以把点(x, y)的坐标变成(x + y, x - y)，从而使得这些点构成一个正方形，正方形的边长为2 * r。注意，这里边长为r的意思是这条边能容纳r+1个格点。
//事实上，在新的坐标系下，切比雪夫距离就是曼哈顿距离。

于是问题转化为找到一个边长为r的正方形，使得被该正方形包含的点的数目最大。

假设某个点在(x, y)处，我们可以把这个点拆成(x + 1, y + 1, 1)，(x - r, y - r, 1)，(x - r, y + 1, -1)，(x + 1, y - r, -1)。第三个维度是权值。

假设正方形的左下角为(x0, y0)，那么当原先的点被该正方形覆盖，则(x0, y0)的前缀和就会加上1，否则加上0。
于是正方形框住的点数就是新图中正方形左下角所在点的前缀和，原问题转化为求最大前缀和。
构造一个线段树，支持区间加和查询区间最大值，元素初始化为0。先对所有点按x和y排序（x优先），然后从下往上，逐行处理，每读到一个点(x1, y1, v)，就在线段树中对区间[y1, maxy] 减v。处理完一行后，线段树中的值就是每个点的前缀和，查询整个区间的最大值并更新答案。所有行处理完后答案就出来了。

code:
```cpp
#include <cstdio>
#include <algorithm>

using namespace std;

//(2e6 + 2e6) + 1e6
#define MAXX 5000010
//(2e6 - (-2e6)) + 1e6
#define MAXY 5000010

#define MAXN 300010

const int offsetx = 1000000;
const int offsety = 1000000;
const int offsety2 = 2000000;
const int maxx = MAXX - 5;
const int maxy = MAXY - 5;

struct P {
	int x, y, w;
	bool operator < (const P& rhs) const {
		return x != rhs.x ? x < rhs.x : (y != rhs.y ? y < rhs.y : false);
		//return y != rhs.y ? y < rhs.y : (x != rhs.x ? x < rhs.x : false);
	}
};

#define MAX_NODE_SEGTREE (MAXY << 2)
struct SegTree {
	int maxi[MAX_NODE_SEGTREE], lazy[MAX_NODE_SEGTREE];

	inline int ls(int rt) {
		return rt << 1;
	}
	inline int rs(int rt) {
		return rt << 1 | 1;
	}
	void PushUp(int rt) {
		maxi[rt] = max(maxi[ls(rt)], maxi[rs(rt)]);
	}
	void PushDown(int rt) {
		if (lazy[rt]) {
			lazy[ls(rt)] += lazy[rt];
			lazy[rs(rt)] += lazy[rt];
			maxi[ls(rt)] += lazy[rt];
			maxi[rs(rt)] += lazy[rt];
			lazy[rt] = 0;
		}
	}
	void Add(int rt, int l, int r, int L, int R, int v) {
		if (L <= l && r <= R) {
			lazy[rt] += v;
			maxi[rt] += v;
		} else {
			int mid = (l + r) >> 1;
			PushDown(rt);
			if (L <= mid)
				Add(ls(rt), l, mid, L, R, v);
			if (mid < R)
				Add(rs(rt), mid+1, r, L, R, v);
			PushUp(rt);
		}
	}
	int Max() {
		return maxi[1];
	}
};

int main() {
	int n, r;
	static P points[MAXN * 4];
	static SegTree sgt;

	scanf("%d%d", &n, &r);
	r <<= 1;
	for (int i = 0; i < n; ++i) {
		int x, y;
		scanf("%d%d", &x, &y);
		x += offsetx;
		y += offsety;
		points[i] = P{r + x + y + 1, r + x - y + offsety2 + 1, 1};
	}
	for (int i = 0; i < n; ++i) {
		points[i+n] = P{points[i].x - r, points[i].y - r, 1};
		points[i+2*n] = P{points[i].x - r, points[i].y + 1, -1};
		points[i+3*n] = P{points[i].x + 1, points[i].y - r, -1};
		++points[i].x;
		++points[i].y;
	}
	n <<= 2;
	sort(points, points + n);

	int ans = 0;
	int i = 0;
	while (i < n) {
		int nowx = points[i].x;
		for (; i < n && points[i].x == nowx; ++i) {
			sgt.Add(1, 1, maxy, points[i].y, maxy, points[i].w);
		}
		ans = max(ans, sgt.Max());
	}
	printf("%d", ans);
	
	return 0;
}
```
