---
title: lightoj 1408 Batting Practice
date: 2019-11-06 22:11:33
---

题意：一个人有p的概率**输掉**，如果连续赢k1次或连续输k2次就结束，问结束前打的次数的期望。

定义f(i)为已经连续赢i次时到结束期望的次数，g(i)为已经连续输i次时到结束期望的次数。
则有关系式：
$$f(i) = p f(i+1) + ((1 - p) g(1) + 1)$$
$$g(i) = (1 - p)g(i+1) + p f(1) + 1$$
然后展开一下
记$A = ((1 - p) g(1) + 1)$
$$f(1) = p^{k_1-1} f(k_1) + p^{k_1 - 2} A + p^{k_1 - 3} A + \cdots + A$$
$$f(1) = ((1 - p) g(1) + 1) \frac{p^{k_1 - 1} - 1}{p-1}$$
同理，
$$g(1) = (p f(1) + 1) \frac{1 - (1-p)^{k_2 - 1}}{p}$$
记
$$A = \frac{1 - (1-p)^{k_2 - 1}}{p}$$
$$B = \frac{p^{k_1 - 1} - 1}{p-1}$$
则
$$g(1) = \frac{(pB+1)A}{1 - p(1-p)AB}$$
$$f(1) = ((1 - p) g(1) + 1)B$$
最终答案为
$$f(1)p + g(1)(1-p) + 1$$
代码：
```cpp
#include <cstdio>
#include <cmath>

using namespace std;

#define DEBUG 0

const double eps = 1e-12;

int main() {
    int T;

    scanf("%d", &T);
    for (int Ti = 1; Ti <= T; ++Ti) {
        double p;
        int k1, k2;
        scanf("%lf%d%d", &p, &k1, &k2);
        double ans;
        p = 1 - p;
        if (p < eps) {
            ans = k2;
        } else if (1 - p < eps) {
            ans = k1;
        } else {
            double B = (pow(p, k1 - 1) - 1) / (p - 1);
            double A = (1 - pow(1-p, k2-1)) / p;
            double g1 = (p * B + 1) * A / (1 - p * (1 - p) * A * B);
            double f1 = ((1 - p) * g1 + 1) * B;
            ans = f1 * p + g1 * (1 - p) + 1;
#if DEBUG
            printf("A = %f, B = %f, f1 = %f, g1 = %f\n", A, B, f1, g1);
#endif
        }
        printf("Case %d: %.10f\n", Ti, ans);
    }
    return 0;
}
```
