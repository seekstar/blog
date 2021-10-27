---
title: lightoj 1287 Where to Run
date: 2019-11-07 16:14:32
---

大意：一个无向有权图，权值代表从一个点到另一个点所需时间。有n个点，标号0到n-1，初始点在0。定义一个点是好的，当且仅当这个点没去过，且从这个点能够沿着一条简单路径经过所有没去过的点。如果所在的点周围有cnt个好的点，那么有1/(cnt+1)的概率在当前点停留5min，各有1/(cnt+1)的概率前往周围那些点。当当前点周围没有好的点时终止。问期望的能坚持的时间是多久。
1 <= n <= 15

这么小的数据量当然是状压dp了。

定义f[i][st]为当前点是i，经过的点的集合为st。然后转移方程为
$$f[i][st] = \frac{1}{cnt + 1} (f[i][st] + 5) + \\
\frac{1}{cnt + 1}\sum_{u是好的点} (f[u][st | (1 << u)] + cost(i, u)$$

如何知道一个点是不是好的点呢？用dfs，假装去这个点了，然后递归判断从这个点是否能遍历所有的未经过点。

代码：
```cpp
#include <cstdio>
#include <algorithm>
#include <vector>
#include <cstring>

using namespace std;

#define MAXN 16

typedef pair<int, int> pii;

struct GRAPH {
    vector<vector<pii> > s;

    void ClearEdges() {
        for (auto& i : s)
            i.resize(0);
    }
    void Init(int n) {
        ClearEdges();
        s.resize(n+1);
    }
    void AddUndi(int u, int v, int w) {
        s[u].emplace_back(v, w);
        s[v].emplace_back(u, w);
    }
} g;

const double eps = 1e-12;

int n;
double f[MAXN][1 << MAXN];
bool vis[MAXN][1 << MAXN];
bool res[MAXN][1 << MAXN];
bool dfs(int st, int u) {
    if (vis[u][st]) {
        return res[u][st];
    }
    vis[u][st] = true;
    if (st == (1 << n) - 1) {
        f[u][st] = 0;
        return res[u][st] = true;
    }
    f[u][st] = 5;
    int cnt = 0;
    for (auto& e : g.s[u]) {
        int nxt = st | (1 << e.first);
        if (st != nxt && dfs(nxt, e.first)) {
            ++cnt;
            f[u][st] += f[e.first][nxt] + e.second;
        }
    }
    if (cnt) {
        f[u][st] /= cnt;
        return res[u][st] = true;
    } else {
        f[u][st] = 0;
        return res[u][st] = false;
    }
}
int main() {
    int T;

    scanf("%d", &T);
    for (int Ti = 1; Ti <= T; ++Ti) {
        int m;

        scanf("%d%d", &n, &m);
        g.Init(n);
        while (m--) {
            int u, v, w;
            scanf("%d%d%d", &u, &v, &w);
            g.AddUndi(u, v, w);
        }
        for (int i = 0; i < n; ++i) {
            memset(vis[i], 0, (1 << n) * sizeof(bool));
        }
        dfs(1, 0);
        printf("Case %d: %.10f\n", Ti, f[0][1]);
    }

    return 0;
}
```
