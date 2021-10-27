---
title: 2019 CCPC秦皇岛现场赛A题O(n^2)做法
date: 2019-09-29 21:18:05
---

链接：http://acm.hdu.edu.cn/showproblem.php?pid=6731

可惜了。现场赛用的GCD加hash，然后因为GCD的log刚好是二分的log的3倍，时限2000ms我2038ms被卡掉了。。。

思路：
把任意两个不同的点的向量存到哈希表里，然后对于每一个询问A，先假设A是那个直角，再枚举第二个点B，对答案的贡献就是与AB垂直的向量AC的个数。由于对称性，最后答案要除以2。
然后假设A不是直角，那么枚举直角点B，对答案的贡献就是与AB垂直的向量BC的个数。
两个假设算出来的答案加起来就是最终答案。

现在问题转化为了给定2000规模的向量，如何找与某个向量垂直的向量个数。我们需要定义一个哈希函数使得所有斜率相同的向量得到的哈希值都相同，然后判断斜率是否相等的函数直接用判断分数是否相等的函数就可以了。

假设向量的表示形式为<x, y>，那么斜率的分数表示显然是y / x。然后我们找一个比较小的素数p，容易证明(k*y)/(k*x)=y/x (mod p)。所以定义哈希函数为(y % p) * inv(x % p) % p就可以了。

附上超快手写哈希
代码(4945ms)：
```cpp
#include <iostream>
#include <limits>
#include <algorithm>
#include <functional>
#include <cstring>

using namespace std;

#define MAXN 2011

typedef long long LL;
typedef pair<int, int> pii;

//Get inverse elements of positive integers that are <= bound
template<typename T>
void GetInvs(T invs[], T p, T bound) {
    invs[1] = 1;
    for(int i = 2; i <= bound; ++i)
        invs[i] = (LL)(p - p / i) * invs[p % i] % p;
}

template <typename T>
T Sub(T x, int p) {
    return x < 0 ? x + p : x;
}

struct VEC {
    int x, y;
    VEC operator - (const VEC& b) const {
        return VEC{x - b.x, y - b.y};
    }
    VEC rotleft() {
        return VEC{-y, x};
    }
};

struct SLOPE_EQ {
    bool operator () (const VEC& a, const VEC& b) {
        return (LL)a.y * b.x == (LL)a.x * b.y;
    }
};

template <int p>
struct INVS {
    int invs[p];
    INVS() {
        GetInvs(invs, p, p-1);
    }
};
template <int p>
struct SLOPE_HASH {
    static INVS<p> helper;
#define invs helper.invs
    int operator () (VEC x) const {
        x.x %= p;
        x.y %= p;
        if (x.x < 0) {
            x.x = -x.x;
            x.y = -x.y;
        }
        return x.x ? Sub(x.y, p) * invs[x.x] % p : 0;
    }
};
template <int p>
INVS<p> SLOPE_HASH<p>::helper;

template <typename T, int p> struct MyHash;
//2027, 100003, 300017, 1000033, 5000011, 30000023
template <int p, typename key_t, typename val_t, typename Hash = MyHash<key_t, p>, typename Pred = equal_to<key_t> >
struct HashMap {
    Hash hasher;
    Pred key_eq;
    val_t NOT_FOUND = numeric_limits<val_t>::min();
    int hd[p], nxt[p], tot;
    key_t keys[p];
    val_t vals[p];
    void Init() {
        tot = 0;
        memset(hd, -1, sizeof(hd));
    }
    //find first if you do not want to shadow
    void emplace_shadow(const key_t& key, const val_t& val) {
        //Shadow the previous one
        int ha = hasher(key);
        nxt[++tot] = hd[ha];
        hd[ha] = tot;
        keys[tot] = key;
        vals[tot] = val;
    }
    val_t& find(key_t key) {
        int ha = hasher(key);
        for (int e = hd[ha]; ~e; e = nxt[e])
            if (key_eq(keys[e], key))
                return vals[e];
        return NOT_FOUND;
    }
};

const int p = 2027;
typedef HashMap<p, VEC, int, SLOPE_HASH<p>, SLOPE_EQ> MyHashMap;

void Insert(MyHashMap& ha, const VEC& now) {
    int& x = ha.find(now);
    if (x == ha.NOT_FOUND) {
        ha.emplace_shadow(now, 1);
    } else {
        ++x;
    }
}
int Find(MyHashMap& ha, const VEC& now) {
    int& x = ha.find(now);
    return x == ha.NOT_FOUND ? 0 : x;
}
int main() {
    static VEC ps[MAXN];
    static MyHashMap rec[MAXN], as;
    int n, q;
    while (cin >> n >> q) {
        for (int i = 0; i < n; ++i) {
            rec[i].Init();
        }
        as.Init();
        for (int i = 0; i < n; ++i) {
            cin >> ps[i].x >> ps[i].y;
        }
        for (int i = 0; i < n; ++i) {
            for (int j = 0; j < n; ++j) {
                if (i != j) {
                    Insert(rec[i], ps[j] - ps[i]);
                }
            }
        }
        while (q--) {
            VEC a;
            cin >> a.x >> a.y;
            as.Init();
            for (int i = 0; i < n; ++i) {
                Insert(as, ps[i] - a);
            }
            LL ans = 0;
            for (int i = 0; i < n; ++i) {
                ans += Find(as, (ps[i] - a).rotleft());
            }
            ans >>= 1;
            for (int i = 0; i < n; ++i) {
                ans += Find(rec[i], (a - ps[i]).rotleft());
            }
            cout << ans << endl;
        }
    }

    return 0;
}
```

用unordered_map直接MLE了。HDU给的内存太少了（现场赛直接给了2G内存的）
代码：
```cpp
#include <iostream>
#include <unordered_map>

using namespace std;

#define MAXN 2011

typedef long long LL;

//Get inverse elements of positive integers that are <= bound
template<typename T>
void GetInvs(T invs[], T p, T bound) {
    invs[1] = 1;
    for(int i = 2; i <= bound; ++i)
        invs[i] = (LL)(p - p / i) * invs[p % i] % p;
}

template <typename T>
T Sub(T x, int p) {
    return x < 0 ? x + p : x;
}

struct VEC {
    int x, y;
    VEC operator - (const VEC& b) const {
        return VEC{x - b.x, y - b.y};
    }
    VEC rotleft() {
        return VEC{-y, x};
    }
};

struct SLOPE_EQ {
    bool operator () (const VEC& a, const VEC& b) const {
        return (LL)a.y * b.x == (LL)a.x * b.y;
    }
};

const int p = 2027;
int invs[p];
struct SLOPE_HASH {
    int operator () (VEC x) const {
        x.x %= p;
        x.y %= p;
        if (x.x < 0) {
            x.x = -x.x;
            x.y = -x.y;
        }
        return x.x ? Sub(x.y, p) * invs[x.x] % p : 0;
    }
};

typedef unordered_map<VEC, int, SLOPE_HASH, SLOPE_EQ> MyHashMap;

void Insert(MyHashMap& ha, const VEC& now) {
    auto it = ha.find(now);
    if (it == ha.end()) {
        ha[now] = 1;
    } else {
        ++it->second;
    }
}
int Find(const MyHashMap& ha, const VEC& now) {
    auto it = ha.find(now);
    return it == ha.end() ? 0 : it->second;
}
int main() {
    static VEC ps[MAXN];
    static MyHashMap rec[MAXN], as;

    GetInvs(invs, p, p-1);
    for (int i = 0; i < MAXN; ++i) {
        rec[i].reserve(p);
    }
    as.reserve(p);
    int n, q;
    while (cin >> n >> q) {
        for (int i = 0; i < n; ++i) {
            cin >> ps[i].x >> ps[i].y;
        }
        for (int i = 0; i < n; ++i) {
            for (int j = 0; j < n; ++j) {
                if (i != j) {
                    Insert(rec[i], ps[j] - ps[i]);
                }
            }
        }
        while (q--) {
            VEC a;
            cin >> a.x >> a.y;
            as.clear();
            for (int i = 0; i < n; ++i) {
                Insert(as, ps[i] - a);
            }
            LL ans = 0;
            for (int i = 0; i < n; ++i) {
                ans += Find(as, (ps[i] - a).rotleft());
            }
            ans >>= 1;
            for (int i = 0; i < n; ++i) {
                ans += Find(rec[i], (a - ps[i]).rotleft());
            }
            cout << ans << endl;
        }
        for (int i = 0; i < n; ++i) {
            rec[i].clear();
        }
        as.clear();
    }

    return 0;
}
```

还有二分版（O(n^2 log n)，8330ms）
```cpp
#include <iostream>
#include <algorithm>

using namespace std;

#define MAXN 2011

typedef long long LL;

struct VEC {
    int x, y;
    void clean() {
        if (x < 0) {
            x = -x;
            y = -y;
        } else if (0 == x) {
            y = abs(y);
        }
    }
    bool operator < (const VEC& b) const {
        return (LL)y * b.x < (LL)x * b.y;
    }
    VEC operator - (const VEC& b) const {
        return VEC{x - b.x, y - b.y};
    }
    VEC rotleft() {
        return VEC{-y, x};
    }
};
int main() {
    int n, q;
    static VEC ps[MAXN], recs[MAXN][MAXN], as[MAXN];
    while (cin >> n >> q) {
        for (int i = 0; i < n; ++i) {
            cin >> ps[i].x >> ps[i].y;
        }
        for (int i = 0; i < n; ++i) {
            int t = 0;
            for (int j = 0; j < n; ++j) {
                if (i == j) continue;
                recs[i][t] = ps[j] - ps[i];
                recs[i][t].clean();
                ++t;
            }
            sort(recs[i], recs[i] + t);
        }
        while (q--) {
            VEC A;
            LL ans = 0;
            cin >> A.x >> A.y;
            for (int i = 0; i < n; ++i) {
                (as[i] = ps[i] - A).clean();
            }
            sort(as, as + n);
            for (int i = 0; i < n; ++i) {
                VEC b = (ps[i] - A).rotleft();
                b.clean();
                ans += upper_bound(as, as + n, b) - lower_bound(as, as + n, b);
            }
            ans >>= 1;
            for (int i = 0; i < n; ++i) {
                VEC b = (A - ps[i]).rotleft();
                b.clean();
                ans += upper_bound(recs[i], recs[i] + n - 1, b) - lower_bound(recs[i], recs[i] + n - 1, b);
            }
            cout << ans << endl;
        }
    }

    return 0;
}
```
