---
title: luogu 2371墨墨的等式
date: 2019-11-06 10:09:23
---

数论转图论神仙题。

题意可以理解为，有n个物品，第i个物品价值为a[i]，每个物品能使用任意次，求在区间[B_min, B_max]中能凑出多少中价值。其中n <= 12, 0 <= a[i] <= 5e5, 1 <= B_min <= B_max <= 1e12

下面假设a都不为0。
以a[0]为例，如果k a[0] + b可以被凑出，那么(k+1)a[0]+b也可以被凑出。所以为了求出所有能被凑出的数，我们要计算对于每个b，k最小能为多少。
在模a[0]意义下，b在加上一个物品a[i]后，变成(b + a[i]) % a[0]，然后实际的总价值增加a[i]。所以我们可以这样构建一个图：
对于每个0到a[0]-1的b，以及每个0到n-1的i，连一条从b到(b + a[i]) % a[0]，边权为a[i]的有向边。
这样，从0转移到b有多条路径，每条路径的权值即为实际凑出的价值。
而我们要求转移到b的最小价值是多少。
这就可以用最短路做。
求出最小价值之后，后面的价值都能被凑出来。所以对于每个b统计一下答案，然后加起来就好了。

代码：
```cpp
#include <iostream>
#include <algorithm>
#include <vector>
#include <queue>

using namespace std;

#define DEBUG 0

#define MAXN 15
#define MAXA 500011

typedef long long LL;

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
        s.resize(n+1);
    }
    void AddDi(int u, int v, int w) {
        s[u].emplace_back(make_pair(v, w));
    }
};

template <typename T>
void dijkstra(const GRAPH& g, int s, T dist[]) {
    priority_queue<pair<T, int> >q;

    fill(dist, dist + g.s.size(), numeric_limits<T>::max());
    dist[s] = 0;
    q.push(make_pair(0, s));
    while (!q.empty()) {
        s = q.top().second;
        T c = -q.top().first;
        q.pop();
        if (c > dist[s]) continue;//old version
        for (auto i : g.s[s]) {
            int v = i.first;
            c = i.second;
            if (dist[v] > dist[s] + c) {
                dist[v] = dist[s] + c;
                q.push(make_pair(-dist[v], v));
            }
        }
    }
}

int main() {
    static int a[MAXN];
    static LL dist[MAXA];

    int t;
    LL b0, b1;
    cin >> t >> b0 >> b1;
    --b0;
    int n = 0;
    while (t--) {
        int ta;
        cin >> ta;
        if (ta) {
            a[n++] = ta;
        }
    }
    if (n) {
        int mn = a[0];
        for (int i = 1; i < n; ++i) {
            if (a[i]) {
                mn = min(mn, a[i]);
            }
        }
        GRAPH g;
        g.Init(mn);
        for (int i = 0; i < n; ++i) {
            for (int j = 0; j < mn; ++j) {
                g.AddDi(j, (j + a[i]) % mn, a[i]);
            }
        }
        dijkstra(g, 0, dist);
#if DEBUG
        for (int i = 0; i < mn; ++i) {
            cout << dist[i] << ' ';
        }
        cout << endl;
#endif
        LL ans = 0;
        for (int i = 0; i < mn; ++i) {
            LL up = b1 / mn + 1;    //The included numbers
            if (b1 % mn < i)
                --up;
            LL down = b0 / mn + 1;
            if (b0 % mn < i)
                --down;
            down = max(down, dist[i] / mn);
            if (up >= down) {
                ans += up - down;
            }
        }
        cout << ans << endl;
    } else {
        cout << "0\n";
    }
    return 0;
}
```
