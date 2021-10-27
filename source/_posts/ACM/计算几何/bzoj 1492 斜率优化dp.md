---
title: bzoj 1492 斜率优化dp
date: 2019-10-31 22:18:28
---

设f[i]为第i天出售后最多能得到的钱数，枚举最后一次买入的天数j，那么有转移方程：
$$f[i] = \frac{f[j]}{a[j] r[j] + b[j]} b[i] + \frac{r[j] f[j]}{a[j] r[j] + b[j]} a[i]$$
化成斜率优化的形式$y(j) = k(i) x(j) + b(i)$
$$\frac{f[j]}{a[j] r[j] + b[j]} = \frac{r[j] f[j]}{a[j] r[j] + b[j]} \frac{-a[i]}{b[i]} + \frac{f[i]}{b[i]}$$
注意到截距b(i)与f(i)成正相关，因此应该用直线切上凸包。
这里斜率和点的坐标显然都不单调，因此要用动态凸包。然后又因为还要在凸包上二分，而set维护的动态凸包不支持凸包上二分，因此要手写平衡树。这里我用的splay维护。

代码（836ms，目前darkbzoj最快）：
```cpp
#include <cstdio>
#include <set>
#include <string>
#include <cmath>

using namespace std;

#define MAXN 1000011

template <typename T>
T sq(T x) {
    return x * x;
}

const double eps = 1e-8, pi = acos(-1.0);
int sgn(double x) {
    return x < -eps ? -1 : (x > eps ? 1 : 0);
}

struct VEC {
    double x, y;
    bool operator == (const VEC& b) const {
        return sgn(x - b.x) == 0 && sgn(y - b.y) == 0;
    }
    bool operator < (const VEC& b) const {
        return sgn(y - b.y) == 0 ? sgn(x - b.x) < 0 : y < b.y;
    }

    VEC operator - (const VEC& b) const {
        return VEC{x - b.x, y - b.y};
    }
    VEC operator + (const VEC& b) const {
        return VEC{x + b.x, y + b.y};
    }

    double len() const {
        return hypot(x, y);
    }
    double dist(const VEC& b) const {
        return (*this - b).len();
    }

    double len2() const {
        return sq(x) + sq(y);
    }
    double dist2(const VEC& b) const {
        return (*this - b).len2();
    }

    VEC operator * (double k) const {
        return VEC{x * k, y * k};
    }
    VEC trunc(double l) const {
        double ori = len();
        if (!sgn(ori)) return *this;
        return *this * (l / ori);
    }

    VEC operator / (double k) const {
        return VEC{x / k, y / k};
    }
    VEC norm() const {
        return *this / len();
    }

    double operator ^ (const VEC& b) const {
        return x * b.y - y * b.x;
    }
    double operator * (const VEC& b) const {
        return x * b.x + y * b.y;
    }
    // The angle between *this and b
    //anticlockwise is plus
    double rad_di(const VEC& b) const {
        return atan2(*this ^ b, *this * b);
    }
    double rad(const VEC& b) const {
        return fabs(rad_di(b));
        //return asin(fabs(*this ^ b) / (len() * b.len()));
    }

    VEC rotleft() const {
        return VEC{-y, x};
    }
    VEC rotright() const {
        return VEC{y, -x};
    }
    VEC rot(double a) const {
        double c = cos(a), s = sin(a);
        return VEC{x * c - y * s, x * s + y * c};
    }

    //Independent
    //0 <= slope < pi
    double slope() const {
        double ans = atan2(y, x);
        if (sgn(ans) < 0) ans += pi;
        else if (sgn(ans - pi) == 0) ans -= pi;
        return ans;
    }

    double cross(const VEC& p1, const VEC& p2) const {
        return (p1 - *this) ^ (p2 - *this);
    }

    //-1: left
    //0: parallel
    //1: right
    int relation(const VEC& b) const {
        return sgn(b ^ *this);
    }

    void input() {
        scanf("%lf%lf", &x, &y);
    }
};

template <typename T, typename Comp>
struct SPLAY {
    //0 is invalid
    int c[MAXN][2], fa[MAXN], tot, root;
    T keys[MAXN];

#define ls(rt) c[rt][0]
#define rs(rt) c[rt][1]
#define Comp Comp()
    void Init() {
        root = tot = 0;
    }
    bool Side(int rt) {
        return rt == rs(fa[rt]);
    }
    void Init(int rt, const T& key) {
        ls(rt) = rs(rt) = fa[rt] = 0;
        keys[rt] = key;
    }
    void SetSon(int x, int f, int s) {
        if (f) c[f][s] = x;
        if (x) fa[x] = f;
    }
    //Will update siz[now] and siz[fa[now]]
    void RotateUp(int now) {
        int f = fa[now];
        bool side = Side(now);
        SetSon(c[now][!side], f, side);
        SetSon(now, fa[f], Side(f));
        SetSon(f, now, !side);
        if (!fa[now])
            root = now;
    }
    void Splay(int now, int to = 0) {
        if (!now) return;
        for (int f = fa[now]; f != to; f = fa[now]) {
            if (fa[f] != to)
                RotateUp(Side(now) == Side(f) ? f : now);
            RotateUp(now);
        }
    }

    //The node will be the root(new or old)
    bool Insert(const T& key) {
        bool ret = true;
        if (!root) {
            Init(root = ++tot, key);
        } else {
            int now = root;
            int f;
            while (true) {
                if (!now) {
                    Init(now = ++tot, key);
                    fa[now] = f;
                    c[f][Comp(keys[f], key)] = now;
                    break;
                } else if (keys[now] == key) {
                    ret = false;
                    break;
                }
                f = now;
                now = c[now][Comp(keys[now], key)];
            }
            Splay(now);
        }
        return ret;
    }

    //The target node will be the root
    int find(const T& key) {
        int now = root;
        while (now && ((Comp(keys[now], key) || Comp(key, keys[now]))))
            now = c[now][Comp(keys[now], key)];
        Splay(now);
        return now;
    }
    //Only go down
    int FindPreOrNext_down(int now, bool nex) const {
        if (!c[now][nex]) return 0;
        nex = !nex;
        for (now = c[now][!nex]; c[now][nex]; now = c[now][nex]);
        return now;
    }
    void DelRoot() {
        int now = FindPreOrNext_down(root, false);
        if (!now) {
            root = rs(root);
            fa[root] = 0;
        } else {
            Splay(now);
            SetSon(rs(rs(root)), root, 1);
        }
        //No need to free the target node
    }
    void Del(const T& key) {
        int now = find(key);
        if (!now) return;
        if (!ls(root) || !rs(root)) {
            root = ls(root) + rs(root);
            fa[root] = 0;	//Even if root == 0, it does no harm
            //No need to free the target node
        } else {
            DelRoot();
        }
    }

    int PreOrNxt(int now, bool nxt) const {
        if (!c[now][nxt]) {
            int f = fa[now];
            while (f && c[f][!nxt] != now) {
                now = f;
                f = fa[now];
            }
            return f;
        } else {
            now = c[now][nxt];
            while (c[now][!nxt]) {
                now = c[now][!nxt];
            }
            return now;
        }
    }
    void erase(int it) {
        Splay(it);
        DelRoot();
    }

    int lower_bound(const T& key, bool nxt) {
        if (!Insert(key)) {
            return root;
        }
        int now = root;
        if (!c[now][nxt]) {
            Del(key);
            return 0;
        }
        now = FindPreOrNext_down(now, nxt);
        Del(key);
        return now;
    }

    int begin() {
        int now = root;
        while (ls(now))
            now = ls(now);
        return now;
    }
    constexpr int end() {
        return 0;
    }

    int lower_bound_slope(double k) {
        int rt = root, nxt, ans = root;
        while (1) {
            if ((nxt = PreOrNxt(rt, true))) {
                VEC d = keys[nxt] - keys[rt];
                if (sgn(d.y - k * d.x) <= 0) {
                    ans = rt;
                    rt = ls(rt);
                } else {
                    rt = rs(rt);
                }
            } else if ((nxt = PreOrNxt(rt, false))) {
                VEC d = keys[rt] - keys[nxt];
                if (sgn(d.y - k * d.x) <= 0) {
                    rt = ls(rt);
                } else {
                    ans = rt;
                    rt = rs(rt);
                }
            } else {
                break;
            }
        }
        return ans;
    }
};

struct up_sgn {
    int operator () (double x) const {
        return -sgn(x);
    }
};
template <class XSGN>
struct HalfConvexHull {
#define xsgn XSGN()
    struct CMPX {
        bool operator () (const VEC& a, const VEC& b) const {
            return xsgn(a.x - b.x) < 0;
        }
    };
    SPLAY<VEC, CMPX> s;

    void Init() {
        s.Init();
    }
    int Pre(int it) {
        return s.PreOrNxt(it, false);
    }
    int Nxt(int it) {
        return s.PreOrNxt(it, true);
    }

    int it;
    //The convex mustn't be degenerate
    //0: out
    //1: on
    //2: in
    int relation(const VEC& p) {
        it = s.lower_bound(p, true);
        if (it == s.end()) return 0;
        if (it == s.begin()) {
            if (xsgn(p.x - s.keys[it].x) < 0) return 0;
            else return xsgn(p.y - s.keys[it].y) + 1;
        }
        int bef = Pre(it);
        return sgn((s.keys[it] - s.keys[bef]) ^ (p - s.keys[bef])) + 1;
    }
    void Insert(const VEC& p) {
        if (relation(p)) return;
        if (it && sgn(s.keys[it].x - p.x) == 0) {
            s.erase(it);
        }
        s.Insert(p);
        it = s.root;    //The new node
        auto pre = Pre(it), nxt = Nxt(it);
        if (pre) {
            for (auto j = Pre(pre); j && sgn((s.keys[pre] - p) ^ (s.keys[j] - p)) >= 0; pre = j, j = Pre(j)) {
                s.erase(pre);
            }
        }
        if (nxt) {
            for (auto j = Nxt(nxt); j && sgn((s.keys[j] - p) ^ (s.keys[nxt] - p)) >= 0; nxt = j, j = Nxt(j)) {
                s.erase(nxt);
            }
        }
    }
};

double a[MAXN], b[MAXN], r[MAXN], f[MAXN];

VEC point(int j) {
    double y = f[j] / (a[j] * r[j] + b[j]);
    return VEC{r[j] * y, y};
}

int main() {
    int n;
    static HalfConvexHull<up_sgn> conv;

    scanf("%d%lf", &n, f + 1);
    for (int i = 1; i <= n; ++i) {
        scanf("%lf%lf%lf", a + i, b + i, r + i);
    }
    conv.Insert(point(1));
    for (int i = 2; i <= n; ++i) {
        double slope = -a[i] / b[i];
        VEC from = conv.s.keys[conv.s.lower_bound_slope(slope)];
        f[i] = max(f[i-1], (from.y - slope * from.x) * b[i]);
        conv.Insert(point(i));
    }
    printf("%.3f\n", f[n]);
    
    return 0;
}
```
