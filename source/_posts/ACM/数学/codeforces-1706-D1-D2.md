---
title: codeforces 1706 D1 D2
date: 2022-07-24 16:27:35
tags:
---

## D1 ($O(na_n\log(n))$)

链接：<https://codeforces.com/contest/1706/problem/D1>

滑动窗口，每个$p_i$从1开始逐渐递增，维护窗口内的最大的和最小的$\lfloor\frac{a_i}{p_i}\rfloor$。每次滑动复杂度$O(log(n))$，每个$a_i$有$a_n$个$p_i$需要遍历，所以复杂度$O(na_n\log(n))$。

代码：

```cpp
#include <cstdio>
#include <queue>

using namespace std;

constexpr int MAXN = 3011;

int main() {
	int T;
	static int a[MAXN];
	static int p[MAXN];

	scanf("%d", &T);
	while (T--) {
		int n, k;
		scanf("%d%d", &n, &k);
		for (int i = 1; i <= n; ++i) {
			scanf("%d", a + i);
		}
		int ans = 0x3f3f3f3f;
		int mn = 0x3f3f3f3f;
		priority_queue<pair<int, int> > pq;
		for (int i = 1; i <= n; ++i) {
			p[i] = 1;
		}
		for (int i = 1; i <= n; ++i) {
			pq.push(make_pair(a[i], i));
			mn = min(mn, a[i]);
		}
		while (1) {
			int mx = pq.top().first;
			int i = pq.top().second;
			pq.pop();
			ans = min(ans, mx - mn);
			if (p[i] == k) {
				break;
			}
			p[i] += 1;
			int v = a[i] / p[i];
			pq.push(make_pair(v, i));
			mn = min(mn, v);
		}
		printf("%d\n", ans);
	}

	return 0;
}
```

## D1 ($O(n\sqrt{a_n}\log(n))$)

注意到$\lfloor\frac{a_i}{p_i}\rfloor$只有$O(\sqrt{a_i})$个可能取值，因此可以用数论分块遍历这$O(\sqrt{a_i})$个可以让$\lfloor\frac{a_i}{p_i}\rfloor$取不同值的$p_i$。复杂度降为$O(n\sqrt{v}\log(n))$。

代码：

```cpp
#include <cstdio>
#include <queue>

using namespace std;

constexpr int MAXN = 3011;

int main() {
	int T;
	static int a[MAXN];
	static int p[MAXN];

	scanf("%d", &T);
	while (T--) {
		int n, k;
		scanf("%d%d", &n, &k);
		for (int i = 1; i <= n; ++i) {
			scanf("%d", a + i);
		}
		int ans = 0x3f3f3f3f;
		int mn = 0x3f3f3f3f;
		priority_queue<pair<int, int> > pq;
		for (int i = 1; i <= n; ++i) {
			p[i] = 1;
		}
		for (int i = 1; i <= n; ++i) {
			pq.push(make_pair(a[i], i));
			mn = min(mn, a[i]);
		}
		while (!pq.empty()) {
			int mx = pq.top().first;
			int i = pq.top().second;
			pq.pop();
			ans = min(ans, mx - mn);
			if (mx == 0)
				break;
			p[i] = a[i] / mx + 1;
			if (p[i] > k)
				break;
			int v = a[i] / p[i];
			pq.push(make_pair(v, i));
			mn = min(mn, v);
		}
		printf("%d\n", ans);
	}

	return 0;
}
```

## D2 ($O(n\sqrt{a_n})$)

D2的n和$a_n$的范围都变成了1e5。考虑如何将维护窗口内的最大的$\lfloor\frac{a_i}{p_i}\rfloor$的复杂度降至$O(1)$。

注意到值域仅为1e5，因此可以采用类似桶排序的思路，搞一个数组$v$，$v_x$表示满足$\lfloor\frac{a_i}{p_i}\rfloor = x$的$i$构成的集合。然后从大到小遍历这个数组，当前遍历到的下标就是当前窗口的$\lfloor\frac{a_i}{p_i}\rfloor$的最大值。

代码：

```cpp
#include <cstdio>
#include <vector>

using namespace std;

constexpr int MAXN = 100011;
constexpr int MAXV = 100011;

int main() {
	int T;
	static int a[MAXN];
	static int p[MAXN];

	scanf("%d", &T);
	while (T--) {
		int n, k;
		scanf("%d%d", &n, &k);
		for (int i = 1; i <= n; ++i) {
			scanf("%d", a + i);
		}
		int ans = 0x3f3f3f3f;
		int mn = 0x3f3f3f3f;
		vector<int> v[MAXV];
		for (int i = 1; i <= n; ++i) {
			p[i] = 1;
		}
		int mx = a[1];
		for (int i = 1; i <= n; ++i) {
			v[a[i]].push_back(i);
			mn = min(mn, a[i]);
			mx = max(mx, a[i]);
		}
		for (; mx; mx -= 1) {
			if (v[mx].empty())
				continue;
			for (int i : v[mx]) {
				ans = min(ans, mx - mn);
				p[i] = a[i] / mx + 1;
				if (p[i] > k)
					goto out;
				int val = a[i] / p[i];
				v[val].push_back(i);
				mn = min(mn, val);
			}
			v[mx] = vector<int>();
		}
out:
		printf("%d\n", ans);
	}

	return 0;
}
```

## D2 ($O(a_n \log(a_n))$)

假设已知$v = \max_{i}(\lfloor\frac{a_i}{p_i}\rfloor)$，那么我们就要最大化（但不大于$v$）每个$\lfloor\frac{a_i}{p_i}\rfloor$。对于每个给定的$a_i$，我们其实可以算出$p_i$：

$\lfloor\frac{a_i}{p_i}\rfloor \le v \Leftrightarrow \frac{a_i}{p_i} < v + 1 \Leftrightarrow p_i > \frac{a_i}{v+1} \Leftrightarrow p_i > \lfloor\frac{a_i}{v+1}\rfloor$

要最大化$\lfloor\frac{a_i}{p_i}\rfloor$，显然$p_i$越小越好，所以$p_i$应该取$\lfloor\frac{a_i}{v+1}\rfloor + 1$。

换句话说，假如$p_i$的取值应该为$u$，那么这个$a_i$应该满足：

$\lfloor\frac{a_i}{v+1}\rfloor + 1 = u \Leftrightarrow u \le \frac{a_i}{v+1} + 1 < u + 1 \Leftrightarrow (u-1)(v+1) \le a_i < u (v+1)$

这里官方题解$a_i$的右边界是闭合的：<https://codeforces.com/blog/entry/105008>。我觉得不对，不然边界上的u就有两种取值了。

这样，我们遍历$u = 1, 2, ..., k$，把$[(u-1)(v+1), u(v+1))$范围内的$a_i$的$p_i$全部设为$u$，即可最大化$\lfloor\frac{a_i}{p_i}\rfloor$的最小值。

但是怎么求出这个最小值呢？注意到对每个$u$，$\lfloor\frac{a_i}{u}\rfloor$的最小值是用$[(u-1)(v+1), u(v+1))$范围内最小的$a_i$取到的，因此维护区间最小值即可。注意到$[(u-1)(v+1), u(v+1))$范围内的区间最小值（如果有的话）和$[(u-1)(v+1), +\infty)$范围内的区间最小值相同，因此可以直接预计算出后缀最大值。遍历u的时候，查看$[(u-1)(v+1), +\infty)$范围内的区间最小值，如果其小于$u(v+1)$，那么它就是要求的区间最小值，算出对应的$\lfloor\frac{a_i}{u}\rfloor$，更新全局最小值。

总的算法流程是枚举最大值$v$，然后枚举$u$，通过找出对应区间最小的$a_i$算出$\lfloor\frac{a_i}{u}\rfloor$的最小值，进而找到全局最小值，从而算出对当前$v$的值的答案。

注意到$v$到底是不是真的全局最大值其实对答案没有影响，因为如果$v$其实不是全局最大值，那么算出来的答案是偏大的。因此直接遍历$v$的值即可。

由于$u$最大为$k$，而遍历$u$时，所有的$a_i$都应该在这里面的某个区间中。所有$u$的区间并为$[0, k(v+1))$，因此应该满足$a_n < k(v+1)$，即$v > \frac{a_n}{k} - 1 \Leftrightarrow v > \lfloor\frac{a_n}{k}\rfloor - 1 \Leftrightarrow v \ge \lfloor\frac{a_n}{k}\rfloor$。因此遍历$v$的值时，应该是从$\lfloor\frac{a_n}{k}\rfloor$遍历到$a_n$。

遍历$u$时，当$a_n < (u-1)(v+1) \Leftrightarrow u > \frac{a_n}{v+1} + 1 \Leftrightarrow u > \lfloor\frac{a_n}{v+1}\rfloor + 1$时，所有$a_i$都已经被区间包含了，这时就可以得到全局最小的$\lfloor\frac{a_i}{p_i}\rfloor$了。因此遍历$u$时应该从1到$\lfloor\frac{a_n}{v+1}\rfloor + 1$。

因此总的复杂度为

$O(\sum_{v=\lfloor\frac{a_n}{k}\rfloor}^{a_n} (\lfloor\frac{a_n}{v+1}\rfloor + 1)) = O(sum_{v=1}^{a_n} \frac{a_n}{v}) = O(a_n \log(a_n))$

代码：

```cpp
#include <cstdio>
#include <vector>

using namespace std;

constexpr int MAXN = 100011;
constexpr int MAXV = 100011;

int main() {
	int T;
	static int a[MAXN];
	static int ge[MAXV];

	scanf("%d", &T);
	while (T--) {
		int n, k;
		scanf("%d%d", &n, &k);
		a[0] = 0;
		for (int i = 1; i <= n; ++i) {
			scanf("%d", a + i);
		}
		for (int i = n; i; --i) {
			for (int j = a[i]; j > a[i-1]; --j) {
				ge[j] = a[i];
			}
		}
		ge[0] = a[1];
		int ans = 0x3f3f3f3f;
		for (int v = a[n] / k; v <= a[n]; ++v) {
			int mn = 0x3f3f3f3f;
			for (int u = 1; u <= a[n] / (v + 1) + 1; ++u) {
				int ai = ge[(u - 1) * (v + 1)];
				if (ai < u * (v + 1)) {
					mn = min(mn, ai / u);
				}
			}
			ans = min(ans, v - mn);
		}
		printf("%d\n", ans);
	}

	return 0;
}
```
