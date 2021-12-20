---
title: O(1) long long快速乘
date: 2019-07-14 19:40:41
---

很久以前做题的时候看到的。
```cpp
inline long long multi(long long x,long long y,long long mod)
{
    long long tmp=(x*y-(long long)((long double)x/mod*y+1.0e-8)*mod);
    return tmp<0 ? tmp+mod : tmp;
}
```
利用了long double 在某些系统下大于64bit的特性。因此如果评测机的long double是64bit时会WA。
由于浮点数的精度限制，mod不能太小，必须在1e18的级别。实测mod = 1e9+7时，x = 1e18，y = 1e18时会错。
