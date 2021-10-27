---
title: hdu 6217 BBP Formula
date: 2019-11-07 20:09:06
---

orz看了题解才会
https://www.cnblogs.com/LzyRapx/p/7802790.html
用我的语言复述一下

把这几项拆开来看。以第一项为例
$$\sum_{k = 0}^{\infty} \frac{4}{16^k(8k+1)} = \sum_{k=0}^{n-1} \frac{4}{16^k(8k+1)} + \sum_{k=n}^{\infty} \frac{4}{16^k(8k+1)}$$

注意到后面那项减小很快，所以后面那项随便算一些项误差就几乎为0了。

下面只看前面那项
$$\sum_{k=0}^{n-1} \frac{4}{16^k(8k+1)}$$
我们要算第n位小数。所以乘上$16^{n-1}$之后，变成了求第一位数。

$$\sum_{k=0}^{n-1} \frac{4 * 16^{n-1-k}}{8k+1}$$
显然整数部分是没用的。所以其实有意义的只有除法的余数。所以上式等价于
$$\sum_{k=0}^{n-1} \frac{4 * 16^{n-1-k} mod (8k+1)}{8k+1}$$
就可以用快速幂了。

其他项同理。
设
$$S(x) = \sum_{k=0}^{n-1} \frac{16^{n-1-k} mod (8k+x)}{8k+x} + 
\sum_{k=n}^{\infty} \frac{1}{16^k(8k+x)}$$
所以最终答案就是
$$4S(1) - 2S(4) - S(5) - S(6)$$
的第一位小数。

代码：
```cpp
#include <cstdio>
#include <cmath>

using namespace std;

typedef long long LL;

template <typename T>
int mpow(int base, T ex, int p) {
    int ans = 1;
    for (; ex; ex >>= 1, base = (LL)base * base % p)
        if (ex & 1)
            ans = (LL)ans * base % p;
    return ans;
}

int n;
double S(int x) {
    double ans = 0;
    for (int k = n; k < n + 22; ++k) {
        ans = fmod(ans + 1 / (pow(16, k) * (8 * k + x)), 1);
    }
    for (int k = 0; k < n; ++k) {
        ans = fmod(ans + (double)mpow(16, n - 1 - k, 8 * k + x) / (8 * k + x), 1);
    }
    return ans;
}

char hex(int x) {
    if (0 <= x && x <= 9) {
        return x + '0';
    } else {
        return x - 10 + 'A';
    }
}

int main() {
    int T;

    scanf("%d", &T);
    for (int Ti = 1; Ti <= T; ++Ti) {
        scanf("%d", &n);
        printf("Case #%d: %d %c\n", Ti, n, hex(fmod(fmod(4 * S(1) - 2 * S(4) - S(5) - S(6), 1) + 1, 1) * 16));
    }
    return 0;
}
```
