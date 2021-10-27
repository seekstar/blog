---
title: bzoj 1502月下柠檬树 Simpson积分
date: 2019-11-03 14:11:15
---

关键点是，水平的圆投影到水平面之后仍然是与原先全等的圆。
然后圆与圆之间通过曲面无缝连接，所以投影下来之后圆与圆之间通过公切线连接。
直接求有点难。把投影区域的上边界当成一个函数，然后套Simpson积分就简单了。
我的实现用了指针从左往右扫，其实没必要，暴力好像还会快一点。

代码(darkbzoj 218ms)：
```cpp
#include <cstdio>
#include <cmath>
#include <algorithm>
#include <unordered_set>
#include <queue>

using namespace std;

#define DEBUG 0

#define MAXN 511

typedef pair<double, int> pdi;

const double eps = 1e-8;
int sgn(double x) {
    return x < -eps ? -1 : (x > eps ? 1 : 0);
}

const double pi = acos(-1);
double cot(double x) {
    return tan(pi / 2 - x);
}

template <typename T>
T sq(T x) {
    return x * x;
}

struct Func {
    bool type;  //0: line, 1: circle
    double l, r;
    double c, R;
    bool operator < (const Func& b) const {
        return l != b.l ? l < b.l : (r < b.r);
    }
    double y(double x) const {
        if (type) {
            return sqrt(sq(R) - sq(x - c));
        } else {
            return c + (R - c) / (r - l) * (x - l);
        }
    }
};
#define fsnow const Func fs[], const unordered_set<int>& now
double Simpson(fsnow, double l, double r) {
    auto f = [&](double x) {
        double y = numeric_limits<double>::min();
        for (int i : now) {
            y = max(y, fs[i].y(x));
        }
        return y;
    };
    return (f(l) + 4 * f((l+r)/2) + f(r)) * (r - l) / 6;
};
double Integrate(fsnow, double l, double r, double eps, double pre) {
    double mid = (l+r) / 2;
    double L = Simpson(fs, now, l, mid), R = Simpson(fs, now, mid, r), delta = L + R - pre;
    return fabs(delta) <= 15*eps ? L + R + delta/15 :
           Integrate(fs, now, l, mid, eps/2, L) + Integrate(fs, now, mid, r, eps/2, R);	//If you TLE, then try not divide 2, i.e. "eps/2" -> "eps"
}
double Integrate(fsnow, double l, double r, double eps) {
    return Integrate(fs, now, l, r, eps, Simpson(fs, now, l, r));
}
double Integrate(Func fs[], int n, double eps) {
    struct REC {
        double r;
        int i;
        bool operator < (const REC& b) const {
            return r > b.r;
        }
    };
    sort(fs, fs + n);
#if DEBUG
    for (int i = 0; i < n; ++i) {
        printf("%d %f %f %f %f\n", fs[i].type, fs[i].l, fs[i].r, fs[i].c, fs[i].R);
    }
#endif
    unordered_set<int> now;
    priority_queue<REC> right;
    double l = fs[0].l, ans = 0;
    for (int i = 0; i < n; ++i) {
        while (!right.empty() && right.top().r < fs[i].l) {
            ans += Integrate(fs, now, l, right.top().r, eps);
            l = right.top().r;
            now.erase(right.top().i);
            right.pop();
        }
        ans += Integrate(fs, now, l, fs[i].l, eps);
        right.push(REC{fs[i].r, i});
        now.insert(i);
        l = fs[i].l;
    }
    while (!right.empty()) {
        ans += Integrate(fs, now, l, right.top().r, eps);
        l = right.top().r;
        now.erase(right.top().i);
        right.pop();
    }
    return ans;
}
#undef fsnow

int main() {
    int n;
    double a;
    static double x[MAXN];
    static double r[MAXN];
    static Func fs[MAXN << 1];

    scanf("%d%lf", &n, &a);
    for (int i = 0; i <= n; ++i) {
        scanf("%lf", x + i);
    }
    for (int i = 1; i <= n; ++i) {
        scanf("%lf", r + i);
    }
    x[0] = 0;
    for (int i = 1; i <= n; ++i) {
        x[i] = x[i-1] + x[i] * cot(a);
    }
#if DEBUG
    printf("%f\n", cot(a));
    for (int i = 0; i <= n; ++i) {
        printf("%f ", x[i]);
    }
    putchar('\n');
#endif
    int tot = 0;
    for (int i = 1; i <= n; ++i) {
        fs[tot++] = Func{true, x[i-1] - r[i], x[i-1] + r[i], x[i-1], r[i]};
    }
    r[n+1] = 0;
    for (int i = 1; i <= n; ++i) {
        double s = (r[i+1] - r[i]) / (x[i] - x[i-1]);
        double d1 = r[i] * s, d2 = r[i+1] * s;
        fs[tot++] = Func{false, x[i-1] - d1, x[i] - d2, sqrt(sq(r[i]) - sq(d1)), sqrt(sq(r[i+1]) - sq(d2))};
    }
    printf("%.2f\n", Integrate(fs, tot, 1e-6) * 2.0);

    return 0;
}
```
