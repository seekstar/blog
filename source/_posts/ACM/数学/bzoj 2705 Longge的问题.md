---
title: bzoj 2705 Longge的问题
date: 2019-11-05 19:14:37
---

求
$$\sum_{i=1}^N gcd(i, N)$$
其中0<N<=2^32

看起来是莫比乌斯反演，其实不是。。。。。。
化一波式子先
$$
   	\sum_{i=1}^N gcd(i, N) = \sum_{d\mid N} d\sum_{i=1}^{\frac N d} [gcd(i, \frac N d) == 1]
$$
然后别化了（手动喷血

后面那个求和号不就是欧拉函数的定义么（手动喷血

然后变成了求$\sum_{d\mid N} \varphi(\frac N d)$

什么？枚举因子个数和求欧拉函数都是$O(\sqrt N)$的，所以总的是O(N)？

注意到这里要求的都是N的因子的欧拉函数的值，因此可以对N质因数分解，然后直接用dfs枚举各质因子的次数来枚举因子，并且在dfs过程中能直接用欧拉函数的公式维护出欧拉函数值，然后复杂度就变成了O(因子的个数)，也就是$O(\sqrt N)$了（手动喷血

代码（48ms）
```cpp
#include <iostream>
#include <vector>

using namespace std;

#define DEBUG 0

typedef long long LL;

template<typename T>
void PrimeFactor(T n, vector<pair<T, int> >& factor) {
    factor.clear();
    for (T i = 2; i * i <= n; ++i) {
        if (n % i == 0) {
            factor.push_back(make_pair(i, 0));
            do {
                n /= i;
                ++factor.back().second;
            } while (n % i == 0);
        }
    }
    if (n != 1)
        factor.push_back(make_pair(n, 1));
}

LL n, ans;
vector<pair<LL, int> > ps;
void dfs(int i, LL phi, LL now) {
    if (i == ps.size()) {
        ans += phi * (n / now);
    } else {
        dfs(i + 1, phi, now);
        phi *= (ps[i].first - 1);
        now *= ps[i].first;
        for (int j = 1; j <= ps[i].second; ++j) {
            dfs(i + 1, phi, now);
            phi *= ps[i].first;
            now *= ps[i].first;
        }
    }
}
int main() {
    cin >> n;
    PrimeFactor(n, ps);
#if DEBUG
    for (auto pa : ps) {
        cout << pa.first << ' ' << pa.second << endl;
    }
    cout << endl;
#endif

    dfs(0, 1, 1);
    cout << ans << endl;

    return 0;
}
```
