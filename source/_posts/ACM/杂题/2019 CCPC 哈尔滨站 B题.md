---
title: 2019 CCPC 哈尔滨站 B题
date: 2019-11-05 13:40:30
---

链接：https://codeforces.com/gym/102394/problem/B

首先要发现一个性质：
如果i >=  j >= k，那么f(i, k) <= f(j, k)
感性理解一下，就是在同一方向，离自己越近的与自己的公共前缀越长。因为离自己更远的数，最高的与自己不同的数位肯定要不会低于离自己更近的数的最高的与自己不同的数位。

然后对于第i组，在1 ~ i-1组的方向上，在第i组的数中，L[i]显然是与A[i]的f值最小的，而且是与A[i-1]的f值最大的。因此如果满足了f(A[i], L[i]) >= f(A[i-1], L[i])，那么A[1]到A[i-1]都满足了题目的限制。i+1 ~ n组的方向上同理。

然后就可以发现，第1到i-1组和第i+1到n组互不影响，于是就有dp性质，考虑用dp求解。

假设j所在组为i。设dp[j]为选择j为A[i]时，第1到i组时的答案。
我们需要找到所有第i-1组中能够满足f(j, L[i]) >= f(A[i-1], L[i])且f(A[i-1], R[i-1]) >= f(j, R[i-1])的A[i-1]，把这些方案的加起来乘上j就是dp[j]的值了。由于f具有单调性，可以用双指针维护出这个A[i-1]的可选区间。

代码（gym上 46ms）
```cpp
#include <cstdio>

using namespace std;

#define DEBUG 0

#define MAXN (1 << 19)

typedef long long LL;

const int p = 100000007;

template <typename T>
void AddMod(T& x) {
    if (x >= p)
        x -= p;
}
template <typename T>
void SubMod(T& x) {
    if (x < 0)
        x += p;
}

int m;
int f(int x, int y) {
    int i;
    for (i = m - 1; i >= 0 && ((x & (1 << i)) == (y & (1 << i))); --i);
    return m - i - 1;
}

int main() {
    int T;
    static int le[MAXN], ri[MAXN], dp[MAXN];

    scanf("%d", &T);
    while (T--) {
        int n;
        scanf("%d%d", &m, &n);
        for (int i = 0; i < n; ++i) {
            scanf("%d%d", le + i, ri + i);
        }
        for (int j = le[0]; j <= ri[0]; ++j) {
            dp[j] = j % p;
        }
        for (int i = 1; i < n; ++i) {
            int sum = 0;
            int up = le[i-1], down = le[i-1];
            int sp = le[i];
            for (int j = ri[i]; j >= le[i]; --j) {
                while (up <= ri[i-1] && f(up, sp) <= f(j, sp)) {
                    AddMod(sum += dp[up]);
                    ++up;
                }
                while (down <= up && f(down, sp-1) < f(j, sp-1)) {
                    SubMod(sum -= dp[down]);
                    ++down;
                }
                dp[j] = (LL)sum * j % p;
            }
#if DEBUG
            for (int i = 0; i <= ri[n-1]; ++i) {
                printf("%d ", dp[i]);
            }
            putchar('\n');
#endif
        }
        int ans = 0;
        for (int i = le[n-1]; i <= ri[n-1]; ++i) {
            AddMod(ans += dp[i]);
        }
        printf("%d\n", ans);
    }
    return 0;
}
```
