---
title: RSA加密算法的数学原理及时间复杂度分析
date: 2020-04-22 23:21:54
tags:
---

这个东西在打ACM的时候接触过，觉得挺有意思的。

参考：
<https://www.cnblogs.com/idreamo/p/9411265.html>
<https://www.cnblogs.com/coolYuan/p/9168284.html>

# 写在前面
以下大多数描述的目的是方便理解，不是严格的数学语言（要写成严格的数学语言也太难了orz）。
由于涉及的整数位数不多，所以下文中默认大整数乘法是朴素的大整数乘法，没有用到FFT。
# 找到大素数p，q
根据上面的参考文档的说法，至少200位。

可以先生成两个大随机数p'和q'，然后一直加1，用Miller Rabin判断是不是素数。

假如从x开始逐个往上找素数，则Miller Rabin是$O(log(x))$的，而由于素数密度约为$\frac{1}{ln(x)}$，所以大约测试$O(ln(x))$个即可找到一个素数，所以总的复杂度为$O(log^2(x))$的，虽然找到的大素数有很小的概率其实不是素数。

综上，可以在大约$O(log^2(p) + log^2(q))$的时间内找到p和q。
但是p和q是需要求的值，怎么可以拿它们来作为复杂度的估计呢？要是能知道p和q的上界就好了。

可以先用大量算力求出一个大量级的素数，设为P，只要上文的p'和q'小于P，p和q就不超过P了。这样，找到p和q的时间复杂度就是$O(log^2(P))$

# 定义n = p * q
大数乘法。复杂度为$O(log(p) log(q))$，即$O(log^2(P))$。

# 找到e，使得e与(p-1)(q-1)互素
只需要从3开始往上逐个测试素数，直到找到一个不为$(p-1)(q-1)$的素因子的素数。

由于$(p-1)(q-1)$小于$P^2$，所以可以先用大量算力，求出最小的X，使得X以内的素数的乘积大于$P^2$。用线性素数筛把X以内的素数筛出来，在这些素数里就可以找到一个不为$(p-1)(q-1)$的素因子的素数。

（感谢评论区的zzyyyl大佬）由于x以内素数的乘积是$O(e^x)$的，所以X是$O(log(P^2))$即$O(log(P))$的。所以e也是$O(log(P))$的。由于素数密度大约是$\frac{1}{ln(x)}$，所以X以内的素数个数大概是$O(\frac{X}{log(X)})$即$O(\frac{log(P)}{log(log(P))})$。

验证时只需检查能否整除$(p-1)(q-1)$，由于e一般比较小，可以用int存下，所以验证是否整除的时间复杂度为$O(log(pq))$即$O(log(P))$。所以总的复杂度约为$O(\frac{log^2(P)}{log(log(P))})$。

由于e一般比较小，在上述计算方式下，e是$O(log(P))$的，所以把e和n公开，
**(e,n)当作公钥**。

# 设$d \equiv e^{-1}\pmod{(p-1)(q-1)}$
前面规定了e与(p-1)(q-1)互素，所以e有关于(p-1)(q-1)的乘法逆元。可以用拓展欧几里得算法求解。

exgcd的C++代码
```cpp
template<typename T>
void exgcd(const T& a, const T& b, T& x, T& y) {
    if(b == 0) {
        x = 1;
        y = 0;
        return;
    }
    exgcd(b, a%b, x, y);
    T tmp = x;
    x = y;
    y = tmp - a / b * y;
}
template<typename T>
T Inv(const T& num, const T& p) {
    T ans, tmp;
    exgcd(num, p, ans, tmp);
    return (ans % p + p) % p;
}
```
exgcd迭代深度为$O(log(e))$，但是大整数运算只有常数次，所以总复杂度为$O(log(e) + log(pq))$即$O(log(log(P)) + log(P))$即$O(log(P))$。

由于进行取逆元运算之后的值的分布比较随机，所以d的量级一般与(p-1)(q-1)的差不多，所以把
**(d,n)当作私钥**。

# 生成密钥复杂度
综上，大约为$O(log^2(P))$

# 加密
已知原文a，要求密文b，a,b<n
$$b \equiv a ^ e \pmod n$$

显然b只有一种可能取值。

进行$log(e)$次乘法，每次$log^2(n)$，所以复杂度为$O(log(e) log^2(n))$即$O(log(log(P))log^2(P))$。

# 解密
$$a \equiv b ^ d \pmod n \tag{1}$$
同理，复杂度为$O(log(d) log^2(n))$即$O(log^3(P))$。
所以**解密开销比加密高**。

下面证明(1)式成立

### 引理1
在RSA应用环境下，即使a与n不互素，也有
$$a^{1+k\varphi(n)} \equiv a \pmod n$$

证明：
由[这篇文章](https://blog.csdn.net/qq_25847123/article/details/103141321)知即使a与n不互素，也有
$$a^{1+\varphi(n)} \equiv a \pmod n$$
所以
$$a^{1+k\varphi(n)} \equiv a \cdot a^{k\varphi(n)} \equiv a^{1 + \varphi(n)} \cdot a^{k\varphi(n)} \equiv a^{1 + (k+1)\varphi(n)} \pmod n$$
由数学归纳法知
$$a^{1+k\varphi(n)} \equiv a \pmod n$$

### 定理
$$a \equiv b ^ d \pmod n$$

证明：
因为
$$d \equiv e^{-1}\pmod{(p-1)(q-1)}$$
所以
$$ed \equiv 1 \pmod{(p-1)(q-1)}$$
即
$$ed = 1 + k\varphi(n)$$

所以
$$b^d \equiv (a^e)^d \equiv a^{de} \equiv a ^ {1 + k\varphi(n)} \equiv a\pmod n$$
证毕


# 数字签名
参考：<https://baike.baidu.com/item/%E6%95%B0%E5%AD%97%E7%AD%BE%E5%90%8D/212550?fr=aladdin>

e与d互为关于$(p-1)(q-1)$的乘法逆元，所以它们其实是等价的。也就是说用d加密的，用e也能解密，原理同上。

在RSA通信过程中，把(e,n)作为公钥的原因无非是因为e一般比较短，所以可以公开。如果把d公开了，用(e,n)作为私钥，由于n是公开的，e又比较小，攻击者很容易就能枚举出e来。

由于e与d在数学上等价，所以可以把d作为数字签名的私钥，把文件加密，别人验证时用公钥e解密，如果成功说明文件确实是用d加密的。

# ssl证书
ssl证书可以验证连接上的服务器是否为真的服务器。数字签名就是ssl证书的基础。

简化流程如下：
1. 第三方可信机构（例如CA）用自己的私钥加密了服务器证书，然后把公钥公开。
2. 客户端向服务器索要证书
3. 服务器返回给客户端自己的证书
4. 客户端用第三方可信机构提供的公钥解密证书，发现解密成功，说明该证书确实是用该机构的私钥加密的
5. 证书里有该服务器的公钥，客户端想要验证服务器是不是真的有这个公钥对应的私钥，于是客户端生成一个随机数，用证书里的公钥加密，然后发给服务器
6. 服务器用自己的私钥解开，然后发给客户端
7. 客户端收到了正确的随机数，就知道现在跟自己通信的服务器是真的，就放心通信了。

orz
