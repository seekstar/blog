---
title: poj 2096概率dp
date: 2019-11-06 10:52:26
---


大意：每个bug有两种属性N和S。N有n种可能取值，S有s种可能取值。bug的属性的分布是等概率的。一个人一天找一个bug，问他找到的bug中有所有属性的期望天数（不需要取遍所有组合，有就行了）。

由于每种属性是等价的，因此状态可以定义为两个属性各自取到的数量。
设dp[i][j]为遇到了i种N属性，j种S属性的情况下，遇到所有的属性的期望天数。显然dp[n][s] = 0，而dp[0][0]为所求。

接下来，

遇到一个新的N属性，但是属性S是旧的的概率为(n - i) * j / (n * s)，转移到dp[i+1][j]

遇到旧的N属性，新的S属性的概率为i * (s-j) / (n * s)，转移到dp[i][j+1]

两种属性都是新的的概率为(n-i)*(s-j) / (n * s)，转移到dp[i+1][j+1]

两种属性都是旧的的概率为i*s/(n*s)，还是留在dp[i][j]

形式化：

dp[i][j] = i*j/(n*s) dp[i][j] + (n-i)*(s-j) / (n * s) dp[i+1][j+1] + i * (s-j) / (n * s) dp[i][j+1]  + (n - i) * j / 
(n * s) dp[i+1][j] + 1

即

dp[i][j] = ((n-i)*(s-j) * dp[i+1][j+1] + i * (s-j) * dp[i][j+1]  + (n-i) * j * dp[i+1][j] + n * s) / (n*s - i*j)

注意i == n且j == s时要continue

代码：
```cpp
#include <cstdio>

using namespace std;

#define MAXN 1011

int main() {
    static double dp[MAXN][MAXN];

    int n, s;
    scanf("%d%d", &n, &s);
    dp[n][s] = 0;
    for (int i = n; i >= 0; --i) {
        for (int j = s; j >= 0; --j) {
            if (i == n && j == s) continue;
            dp[i][j] = ((n-i)*(s-j) * dp[i+1][j+1] + i * (s-j) * dp[i][j+1]  + (n-i) * j * dp[i+1][j] + n * s) / (n*s - i*j);
        }
    }
    printf("%.4f\n", dp[0][0]);

    return 0;
}
```
