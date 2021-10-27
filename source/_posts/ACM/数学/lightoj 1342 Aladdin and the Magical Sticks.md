---
title: lightoj 1342 Aladdin and the Magical Sticks
date: 2019-11-07 08:58:55
---

题意：有n根棍子，第i根重量为a[i]，有两种棍子，类1拿了一次之后不放回，类2拿了一次之后放回。随机拿棍子，把所有棍子都拿一遍后停下来，问每次拿棍子的重量之和的期望是多少。

先介绍O(n^2)的做法（536ms）
显然棍子的重量与拿棍子是无关的。因此我们可以定义与重量无关的状态。
设类2棍子的总个数为m，f[i][j]为有i根类1棍子和j根类2棍子没拿时，把所有棍子都拿一遍，拿类2棍子的期望总次数。
f[i][j] = i / (i + m) f[i-1][j] + j / (i + m) f(i, j-1) + (m-j) / (i+m) f[i][j] + m / (i + m)

f[i][j] = (i f[i-1][j] + j f[i][j-1] + m) / (i + j)

注意i = 0, j = 0时直接continue掉。

由于拿棍子与重量无关，所以重量可以随便赋值到这些棍子。把这些重量的组合加起来平均一下就是期望了（严格证明我也不会）

假如类1棍子共n根，则最后答案是类1棍子的重量之和加上$f[n][m] * \bar w$，$\bar w$是类2的重量的平均值。

代码：
```cpp
#include <cstdio>
#include <algorithm>

using namespace std;

#define DEBUG 0

#define MAXN 5011

int main() {
    int T;
    static double base[2][MAXN];

    scanf("%d", &T);
    for (int Ti = 1; Ti <= T; ++Ti) {
        int t;
        scanf("%d", &t);
        int n = 0, m = 0;
        double sum = 0, b = 0;
        while (t--) {
            int type, a;
            scanf("%d%d", &a, &type);
            if (1 == type) {
                ++n;
                sum += a;
            } else {
                b += a;
                ++m;
            }
        }
        if (m) {
            double *f = base[0], *g = base[1];
            for (int i = 0; i <= n; ++i) {
                for (int j = 0; j <= m; ++j) {
                    g[j] = 0;
                    if (i) {
                        g[j] = f[j] * i;
                    } else if (!j) continue;
                    if (j) {
                        g[j] += g[j-1] * j;
                    }
                    g[j] += m;
                    g[j] /= (i + j);
                }
                swap(f, g);
            }
            b /= m;
            sum += f[m] * b;
        }
        printf("Case %d: %.10f\n", Ti, sum);
    }
    return 0;
}
```

上网看了一下题解，发现还有线性做法。

我们先解决这样一个问题：从n根棍子里随便拿，拿出来后放回，每根棍子期望拿几回后，每根棍子都被拿出过。

假设所求的是g[n]，总的拿出来的次数是f[n]。拿出第一根后，还有n-1根没有拿。去拿这n-1根中的一根的概率是(n-1)/n，所以
f[n] = 1 + f[n-1] * n / (n-1)

g[n] = f[n] / n

所以g[n] = g[n-1] + 1 / n

现在回到原问题。我们可以假设类1的棍子也是要放回的，但是除了第一次拿起要统计重量外，其他都不统计重量。假设棍子总数量为n，那么每根类2棍子期望拿起的次数都为g[n]。所以最终答案为类1棍子的重量和+类2棍子的重量和*g[n]

代码：
```cpp
#include <cstdio>

using namespace std;

#define MAXN 5011

int main() {
    int T;
    static double h[MAXN];

    h[0] = 0;
    for (int i = 1; i < MAXN; ++i) {
        h[i] = h[i-1] + 1.0 / i;
    }

    scanf("%d", &T);
    for (int Ti = 1; Ti <= T; ++Ti) {
        int n;
        scanf("%d", &n);
        double sum = 0;
        for (int i = 0; i < n; ++i) {
            int a, b;
            scanf("%d%d", &a, &b);
            if (1 == b) {
                sum += a;
            } else {
                sum += h[n] * a;
            }
        }
        printf("Case %d: %.5f\n", Ti, sum);
    }
    return 0;
}
```
