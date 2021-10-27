---
title: pb_ds库实现支持多个相同的值的名次树
date: 2019-06-30 19:37:05
---

参考的大佬的博客的链接：
https://blog.csdn.net/onepointo/article/details/75083305

```cpp
//luogu_3369
#include <stdio.h>
#include <ext/pb_ds/assoc_container.hpp>
#include <ext/pb_ds/tree_policy.hpp>

using namespace std;
using namespace __gnu_pbds;

typedef long long LL;

tree<LL, null_type, less<LL>, rb_tree_tag, tree_order_statistics_node_update> t;
map<int, int> ma;
void Insert(int v) {
    t.insert(((LL)v << 32) + ++ma[v]);
}

void Delete(int v) {
    auto it = ma.find(v);
    t.erase(((LL)v << 32) + it->second);
    --it->second;
    if (0 == it->second) {
        ma.erase(it);
    }
}

int RankOf(int v) {
    return t.order_of_key((LL)v << 32) + 1;
}

int FindByRank(int r) {
    return *t.find_by_order(r-1) >> 32;
}

int FindPre(int v) {
    auto it = ma.lower_bound(v);
    --it;
    return it->first;
}

int FindNext(int v) {
    return ma.upper_bound(v)->first;
}

int main() {
    int n;
    scanf("%d", &n);
    while (n--) {
        int op, x;
        scanf("%d%d", &op, &x);
        switch (op) {
        case 1:
            Insert(x);
            break;
        case 2:
            Delete(x);
            break;
        case 3:
            printf("%d\n", RankOf(x));
            break;
        case 4:
            printf("%d\n", FindByRank(x));
            break;
        case 5:
            printf("%d\n", FindPre(x));
            break;
        case 6:
            printf("%d\n", FindNext(x));
            break;
        }
    }
    return 0;
}
```
注意如果less\<LL\>不小心写成了less\<int\>，编译器不会报错，但是答案是错的。


另一种不用map来求前驱和后继的比较和谐的方法：

```cpp
//luogu_3369
#include <stdio.h>
#include <ext/pb_ds/assoc_container.hpp>
#include <ext/pb_ds/tree_policy.hpp>

using namespace std;
using namespace __gnu_pbds;

typedef long long LL;

tree<LL, null_type, less<LL>, rb_tree_tag, tree_order_statistics_node_update> t;
map<int, int> ma;
void Insert(int v) {
    t.insert(((LL)v << 32) + ++ma[v]);
}

void Delete(int v) {
    t.erase(((LL)v << 32) + ma[v]--);
}

int RankOf(int v) {
    return t.order_of_key((LL)v << 32) + 1;
}

int FindByRank(int r) {
    return *t.find_by_order(r-1) >> 32;
}

int FindPre(int v) {
    auto it = t.lower_bound((LL)v << 32);
    --it;
    return *it >> 32;
}

int FindNext(int v) {
    return *t.lower_bound((LL)(v+1) << 32) >> 32;
}

int main() {
    int n;
    scanf("%d", &n);
    while (n--) {
        int op, x;
        scanf("%d%d", &op, &x);
        switch (op) {
        case 1:
            Insert(x);
            break;
        case 2:
            Delete(x);
            break;
        case 3:
            printf("%d\n", RankOf(x));
            break;
        case 4:
            printf("%d\n", FindByRank(x));
            break;
        case 5:
            printf("%d\n", FindPre(x));
            break;
        case 6:
            printf("%d\n", FindNext(x));
            break;
        }
    }
    return 0;
}
```


封装版：

```cpp
//luogu_3369
#include <stdio.h>
#include <ext/pb_ds/assoc_container.hpp>
#include <ext/pb_ds/tree_policy.hpp>

using namespace std;
using namespace __gnu_pbds;

template<typename T, typename less>
struct Cmp_MultiSet {
	bool operator () (const pair<T, size_t>& x, const pair<T, size_t>& y) const {
		return less()(x.first, y.first) ? true : (less()(y.first, x.first) ? false : less()(x.second, y.second));
	}
};

template<typename T, typename less>
struct MultiSet {
	tree<pair<T, size_t>, null_type, Cmp_MultiSet<T, less>, rb_tree_tag, tree_order_statistics_node_update> t;
	map<T, size_t> ma;
	void Insert(T v) {
		t.insert(make_pair(v, ++ma[v]));
	}
	void Delete(T v) {
		t.erase(make_pair(v, ma[v]--));
	}
	size_t RankOf(T v) {
		return t.order_of_key(make_pair(v, 0)) + 1;
	}
	T FindByRank(size_t r) {
		return t.find_by_order(r-1)->first;
	}
	T FindPre(T v) {
		auto it = t.lower_bound(make_pair(v, 0));
		return (--it)->first;
	}
	T FindNext(T v) {
		return t.lower_bound(make_pair(v+1, 0))->first;
	}
};

int main() {
	MultiSet<int, less<int> > se;
    int n;
    scanf("%d", &n);
    while (n--) {
        int op, x;
        scanf("%d%d", &op, &x);
        switch (op) {
        case 1:
            se.Insert(x);
            break;
        case 2:
            se.Delete(x);
            break;
        case 3:
            printf("%lu\n", se.RankOf(x));
            break;
        case 4:
            printf("%d\n", se.FindByRank(x));
            break;
        case 5:
            printf("%d\n", se.FindPre(x));
            break;
        case 6:
            printf("%d\n", se.FindNext(x));
            break;
        }
    }
    return 0;
}
```
