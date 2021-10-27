---
title: bzoj 2337 XOR和路径
date: 2019-11-08 13:23:15
---

题意：给一个无向连通图。从点1出发，等概率地从当前点走向邻接的点，走到点n停下来。问路径上经过的边的权值的异或和的期望是多少。重复经过的边要重复异或。
2 <= N <= 100, M <= 10000

单独处理每一个bit。

这题必须从n到i算，因为从点1绕一圈回到点1的路径异或和不一定为0。

设f[i]为从i到n，路径异或和的当前bit为1的概率。则有转移方程
$$f[i] = \frac{\sum_{u与i邻接} (cost(i, u) ? (1-f[u]) : f[u])}{du[i]}, i\neq n$$
$$f[n] = 0$$

注意有自环，加无向边的时候加一次就好了。

```cpp
#include <cstdio>
#include <vector>
#include <cmath>
#include <cassert>
#include <algorithm>
#include <functional>

using namespace std;

#define MAXN 111
#define MAXM 10011

typedef long long LL;

struct EDGE {
    int u, v, w;
};

const double eps = 1e-8;

typedef pair<int, int> pii;

struct GRAPH {
    vector<vector<pii> > s;

    void ClearEdges() {
        for (auto& i : s) {
            i.resize(0);
        }
    }
    void Init(int n) {
        ClearEdges();
        s.resize(n + 1);
    }
    void AddUndi(int u, int v, int w) {
        s[u].emplace_back(v, w);
        if (u != v) s[v].emplace_back(u, w);
    }
};

struct MATRIX {
    vector<vector<double> > s;

    MATRIX() {}
    MATRIX(size_t a, size_t b) {
        resize(a, b);
    }
    inline size_t row() const {
        return s.size();
    }
    inline size_t col() const {
        return s.at(0).size();
    }
    void resize(size_t a, size_t b) {
        s.resize(a);
        for (size_t i = 0; i < a; ++i)
            s[i].resize(b);
    }
    void clear() {
        for (auto& i : s)
            for (auto& j : i)
                j = 0;
    }
    void swap_row(size_t i, size_t j, size_t k = 0) {
        for (; k < col(); ++k)
            swap(s[i][k], s[j][k]);
    }
    //s[i] -= s[j] * d
    void sub_row(size_t i, size_t j, double d, size_t k = 0) {
        for (; k < col(); ++k)
            s[i][k] -= d * s[j][k];
    }
    //O(n^3)
    void ToUpper(MATRIX& b) {
        for (size_t i = 0; i < row(); ++i) {
            double maxv = fabs(s[i][i]);
            size_t mr = i;
            for (size_t j = i + 1; j < row(); ++j) {
                if (maxv < fabs(s[j][i])) {
                    maxv = fabs(s[j][i]);
                    mr = j;
                }
            }
            swap_row(i, mr, i);
            b.swap_row(i, mr);
            if (maxv < eps) continue;
            for (size_t j = i + 1; j < row(); ++j) {
                double d = s[j][i] / s[i][i];
                sub_row(j, i, d, i);
                b.sub_row(j, i, d);
            }
        }
    }
};

//ax = b
//b is ans
void solve_destory(MATRIX& a, MATRIX& b) {
    a.ToUpper(b);
    for (int i = a.row() - 1; i >= 0; --i) {
        assert(fabs(a.s[i][i]) > eps);
        b.s[i][0] /= a.s[i][i];
        for (int j = 0; j < i; ++j) {
            b.s[j][0] -= b.s[i][0] * a.s[j][i];
        }
    }
}

int main() {
    GRAPH g;
    static int du[MAXN];

    int n, m;
    scanf("%d%d", &n, &m);
    g.Init(n);
    for (int i = 0; i < m; ++i) {
        int u, v, w;
        scanf("%d%d%d", &u, &v, &w);
        --u;
        --v;
        g.AddUndi(u, v, w);
        ++du[u];
        if (u != v) {
            ++du[v];
        }
    }

    double ans = 0;
    MATRIX b(n, 1);
    MATRIX a(n, n);
    for (int k = 0; k < 31; ++k) {
        a.clear();
        b.clear();
        int now = 1 << k;
        a.s[n-1][n-1] = 1;
        for (int i = 0; i < n-1; ++i) {
            a.s[i][i] = 1;
            for (auto e : g.s[i]) {
                if (e.second & now) {
                    b.s[i][0] += 1.0 / du[i];
                    a.s[i][e.first] += 1.0 / du[i];
                } else {
                    a.s[i][e.first] -= 1.0 / du[i];
                }
            }
        }
        solve_destory(a, b);
        ans += b.s[0][0] * now;
    }
    printf("%.3f", ans);

    return 0;
}
```
