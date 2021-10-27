---
title: LightOJ-1282 求幂的前三个和后三个有效数字
date: 2019-04-10 23:52:32
tags:
---

一种常见解法见链接：https://blog.csdn.net/gscsdlz/article/details/51886094
我~~数学不好~~想到了一个与众不同的解法。

求结果的前三位时，由于后面的数位对前三位的影响很小，所以不太重要，所以我们只要保证前若干位是精确的即可。这让我们想到可以用浮点数代替整数进行运算，后面不重要的数位会被自然舍弃，只保留前面的数位。
但是有一个问题，那就是浮点数能表示的数是有上限的，如果连续乘太多次会上溢。因此我们可以定义一个函数To1，将输入的double类型的x变成[1,10)上的数。
	
```cpp
template<typename T>
void To1(T& x){
    while(x >= 1){
        x /= 10;
    }
    x *= 10;
}
```
每次运算完之后都把它重新放缩到[1,10)，就可以防止上溢啦。最后结果的前三个十进制数字即为所求。
```cpp
int solve3(int x, int ex){
	double base = x;
    To1(base);
    double ans = 1;
	while(ex){
        if(ex & 1){
            To1(ans *= base);
        }
        if(ex >>= 1){
            To1(base *= base);
        }
    }
    while(ans < 1000)ans *= 10;
    return (int)(ans / 10);
```
但是，放缩会丢失大小信息，如果结果本身没有达到1000，那最后结果就会被过度放大，比如n = 2, k = 8时，结果是64，但是该函数会返回640。所以一开始先检查一下结果是否大于1000，如果不是则直接返回该结果。完整的函数如下：
```cpp
int solve3(int x, int ex){
    LL tmp = 1;
    for(int i = 1; i <= ex; ++i){
        tmp *= x;
        if(tmp >= INT_MAX)break;
    }
    if(tmp < INT_MAX){
        Remain3(tmp);
        return (int)tmp;
    }

    double base = x;
    To1(base);
    double ans = 1;
    while(ex){
        if(ex & 1){
            To1(ans *= base);
        }
        if(ex >>= 1){
            To1(base *= base);
        }
    }
    while(ans < 1000)ans *= 10;
    return (int)(ans / 10);
}
```
其中的Remain3函数提取出输入参数的前三个有效数字：
```cpp
template<typename T>
void Remain3(T& x){
    while(x >= 1000){
        x /= 10;
    }
}
```

求出结果的后三位有效数字用普通的快速幂对1000取模即可。完整AC代码如下：
```cpp
#include <stdio.h>
#include <limits.h>

using namespace std;

typedef long long LL;

template<typename T>
T mpow(T base, int ex, T p)
{
    base %= p;
    T ans = 1;
    while(ex)
    {
        if(ex & 1)
            (ans *= base) %= p;
        if(ex >>= 1)
            (base *= base) %= p;
    }
    return ans;
}

template<typename T>
void To1(T& x){
    while(x >= 1){
        x /= 10;
    }
    x *= 10;
}

template<typename T>
void Remain3(T& x){
    while(x >= 1000){
        x /= 10;
    }
}

int solve3(int x, int ex){
    LL tmp = 1;
    for(int i = 1; i <= ex; ++i){
        tmp *= x;
        if(tmp >= INT_MAX)break;
    }
    if(tmp < INT_MAX){
        Remain3(tmp);
        return (int)tmp;
    }

    double base = x;
    To1(base);
    double ans = 1;
    while(ex){
        if(ex & 1){
            To1(ans *= base);
        }
        if(ex >>= 1){
            To1(base *= base);
        }
    }
    while(ans < 1000)ans *= 10;
    return (int)(ans / 10);
}

int main() {
    int n, k;

    int T;

    int ans_trailing;

    scanf("%d", &T);
    for(int Ti = 1; Ti <= T; ++Ti){
        scanf("%d%d", &n, &k);
        ans_trailing = 1;
        for(int i = 1; i <= k; ++i){
            ans_trailing *= n;
            if(ans_trailing >= 1000)break;
        }

        printf("Case %d: %d ", Ti, solve3(n, k));
        if(ans_trailing >= 1000){
            printf("%03d\n", mpow(n, k, 1000));
        }else{
            printf("%d\n", ans_trailing);
        }
    }
    return 0;
}
```

第一次写题解，如有不妥欢迎指出~
