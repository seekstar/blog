---
title: bzoj 2813 奇妙的Fibonacci
date: 2019-11-05 15:11:52
---

题意：设f为fibonacci数列，询问使得f[j]能整除f[i]的j的个数以及j^2的和。3e6个询问，1 <= i <= 1e7

由定义，f[1] = f[2] = 1，f[i] = f[i-1] + f[i-2]
下面用数学归纳法证明gcd(f[i], f[i-1]) == 1
(1) i = 2时，显然gcd(f[i], f[i-1]) == 1成立。
(2) i > 2时，假设gcd(f[i-1], f[i-2]) == 1成立。
则gcd(f[i-1], f[i-1] + f[i-2]) == 1成立
即gcd(f[i-1], f[i]) == 1
综上，对于任意i >= 2，gcd(f[i], f[i-1]) == 1

然后证明对于i > 2，f[i]能且仅能整除f[k * i]，k >= 1
证明：当i > 2时
记a = f[i], b = f[i+1]
则gcd(a, b) == 1
列个表：
i | i+1 |  i+2 | i+3 | i+4 | i+5 | ... | i+i
-|-|-|-|-|-|-|-
a | b | a+b | a+2b | 2a+3b | 3a+5b | ... | f[i-1]a + f[i] b

所以f[i]能整除f[2i]且f[i]不能整除f[j]，i < j < 2i
再打一个b的系数的表

i+i | i+i+1 |  i+i+2 | i+i+3 | i+i+4 | i+i+5 | ... | i+i+i
-|-|-|-|-|-|-|-
a | b | a+b | a+2b | 2a+3b | 3a+5b | ... | f[i-1]a + f[i] b

跟之前那个表基本一样。我们会发现，让b的系数变成a的倍数，到f[3i]才行。
以此类推，就不太严谨但是形象地证明了：对于i > 2，f[i]能且仅能整除f[k * i]，k >= 1

所以能整除f[i]的数只有f[j]，其中j是i的因子或2（2比较特殊，因为f[2] == 1）
所以用线性筛筛出因子个数和因子平方和即可。
那个2要额外注意，因为本题没有限制j <= i，所以2能对f[1]贡献。

代码
```cpp
#include <cstdio>
#include <bitset>
#include <vector>

using namespace std;

#define DEBUG 0

#define MAXN 3000011
#define MAXC 10000011

typedef long long LL;

const int p = 1000000007;

template <typename T>
void AddMod(T& x, int p) {
    if (x >= p)
        x -= p;
}

//f[i] = the sum of the square of the factors of i
bitset<MAXC> is_prime;
vector<int> prime;
void get(int sum2[], int num[], int n, int p) {
    static int pk[MAXC];
    is_prime.set();
    prime.clear();
    sum2[1] = 1;
    num[1] = 1;
    for (int i = 2; i <= n; ++i) {
        if (is_prime[i]) {
            prime.push_back(i);
            pk[i] = i;
            sum2[i] = ((LL)i * i + 1) % p;
            num[i] = 2;
        }
        for (int pr : prime) {
            int now = i * pr;
            if (now > n) break;
            is_prime[now] = false;
            if (i % pr == 0) {  //pr is the minimum prime factor of i
                pk[now] = pk[i] * pr;
                sum2[now] = (sum2[i] + (LL)sum2[i / pk[i]] * pk[now] % p * pk[now]) % p;
                num[now] = num[i] + num[i / pk[i]];
                break;
            } else {
                pk[now] = pr;
                sum2[now] = (1 + (LL)pk[now] * pk[now]) % p * sum2[i] % p;
                num[now] = num[i] << 1;
            }
        }
    }
}

int main() {
    static int sum2[MAXC], num[MAXC];

    get(sum2, num, MAXC - 1, p);
    for (int i = 1; i < MAXC; i += 2) {
        ++num[i];
        AddMod(sum2[i] += 4, p);
    }

    int q;
    static int qs[MAXN], a, b, c;
    scanf("%d%d%d%d%d", &q, qs + 1, &a, &b, &c);
    for (int i = 2; i <= q; ++i) {
        qs[i] = ((LL)qs[i-1] * a + b) % c + 1;
    }
#if DEBUG
    for (int i = 1; i <= q; ++i) {
        printf("%d ", qs[i]);
    }
    putchar('\n');
#endif
    int sa = 0, sb = 0;
    for (int i = 1; i <= q; ++i) {
        AddMod(sa += num[qs[i]], p);
        AddMod(sb += sum2[qs[i]], p);
    }
    printf("%d\n%d\n", sa, sb);

    return 0;
}
```
