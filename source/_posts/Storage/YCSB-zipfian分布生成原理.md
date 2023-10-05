---
title: YCSB zipfian分布生成原理
date: 2023-10-02 21:54:32
tags:
---

YCSB的zipfian分布生成原理出自这篇论文：[Quickly Generating Billion-Record Synthetic Databases](https://dl.acm.org/doi/pdf/10.1145/191843.191886)

但是里面似乎并没有给出推导。我最开始是尝试从定义出发推导出论文里的形式，但是失败了。后来我尝试从论文里的形式出发逆向推导出原始式子，才成功了。为了方便理解，这里从我逆向推导出的原始公式出发，正向推导出论文里的最终形式。

假如随机变量$X$满足取值范围为1到n，参数为$\theta$的Zipfian分布，即

$$X \sim \mathrm{Zipfian}(n, \theta)$$

那么$X$只能取1到n的正整数，而且取正整数$i$的概率正比于$\frac{1}{i^\theta}$

Riemann zeta function的[原本定义](https://en.wikipedia.org/wiki/Riemann_zeta_function)是: $\zeta(\theta) = \sum_{i=1}^{\infty} \frac{1}{i^\theta}$，但论文里给这个定义加了个参数$n$：$\zeta(\theta, n) = \sum_{i=1}^{n} \frac{1}{i^\theta}$

这样$\mathrm{Zipfian}(n, \theta)$取$i$的概率就可以表示为：

$$f(n, \theta, i) = \frac{1}{i^\theta \zeta(\theta, n)}$$

分布函数

$$F(n, \theta, i) = \sum_{j=1}^i f(n, \theta, j) = \frac{1}{\zeta(\theta, n)} \sum_{j=1}^i \frac{1}{j^\theta} = \frac{\zeta(\theta, i)}{\zeta(\theta, n)}$$

现在，我们从0到1的均匀分布中取一个数$u$。只要我们算出$r$，使其满足$F(n, \theta, r - 1) \le u < F(n, \theta, r)$，那么$r$就是满足$\mathrm{Zipfian}(n, \theta)$分布的。

但是$r$是没有解析解的，因为$F$并不是一个连续函数。然而，我们观察发现，虽然当$i$比较小时，$F(n, \theta, i)$的变化幅度比较大，但是当$i$变大之后，$F(n, \theta, i)$随$i$的变化幅度越来越小趋近于0。所以我们可以认为当$i$足够大之后，$F(n, \theta, i)$就近似一个连续函数了。我们的求解思路就是直接算出$F$的前几项，然后当$u$比较小时，直接根据这些算出来的项把$r$求出来。当$u$超过了预计算的最大值之后，就用跟$F$近似的连续函数把$r$估计出来。

论文里预计算了前2项：

$$F(n, \theta, 1) = \frac{1}{\zeta(\theta, n)}, F(n, \theta, 2) = \frac{\zeta(\theta, 2)}{\zeta(\theta, n)}$$

如果 $u \zeta(\theta, n) < 1$，那么就取结果$r = 1$，如果$u \zeta(\theta, n) < \zeta(\theta, 2) = 1 + (\frac{1}{2})^\theta$，就取结果$r = 2$。

否则，取$r > 2$。$u$此时的值域为$[\frac{\zeta(\theta, 2)}{\zeta(\theta, n)}, 1]$。在进行接下来的步骤前，我们先把它的值域变换回0到1：

$$u' = \frac{1 - u}{1 - \frac{\zeta(\theta, 2)}{\zeta(\theta, n)}}$$

接下来我们使用跟$F$近似的连续函数来估计$r$应该是多少。有两个选择：估计$\sum_{j=3}^i \frac{1}{j^\theta}$，或者估计$\sum_{j=i}^n \frac{1}{j^\theta}$。显然，$i$比较小时，前者随着$i$的增大变化更大，用连续函数近似的话误差较大，而且这个误差随着$i$的增大并不会消失。因此我们选择估计后者。

我们定义一个反向的分布函数$G(n, \theta, i)$，表示在已知$X \ge 3$的情况下，$X \ge i$的概率：

$$G(n, \theta, i) = \frac{\sum_{j=i}^n \frac{1}{j^\theta}}{\zeta(\theta, n) - \zeta(\theta, 2)}, i \ge 3$$

其中，

$$\sum_{j=i}^n \frac{1}{j^\theta} = \frac{1}{n^\theta} \sum_{j=i}^n \frac{1}{(\frac{j}{n})^\theta} = \frac{1}{n^{\theta - 1}} \sum_{j=i}^n \frac{1}{(\frac{j}{n})^\theta} \frac{1}{n}$$

我们假设$i$和$n$都足够大，这样就有

$$\begin{aligned}
\sum_{j=i}^n \frac{1}{j^\theta}
\approx & \frac{1}{n^{\theta - 1}} \int_{\frac{i-1}{n}}^1 \frac{1}{x^\theta} \mathrm{d}x \\
=& n^{1-\theta} \int_{\frac{i-1}{n}}^1 x^{-\theta} \mathrm{d}x \\
=& \frac{n^{1-\theta}}{(1-\theta)} x^{1-\theta} \bigg|_{\frac{i-1}{n}}^{1} \\
=& \frac{n^{1-\theta}}{(1-\theta)} (1 - (\frac{i-1}{n})^{1-\theta})
\end{aligned}$$

$i$取最小值3时，该值为

$$\frac{n^{1-\theta}}{1-\theta}(1 - (\frac{2}{n})^{1 - \theta})$$

那么$G$的近似连续函数：

$$\tilde{G}(n, \theta, i) = \frac{\frac{n^{1-\theta}}{(1-\theta)} (1 - (\frac{i-1}{n})^{1-\theta})}{\frac{n^{1-\theta}}{1-\theta}(1 - (\frac{2}{n})^{1 - \theta})} = \frac{1 - (\frac{i-1}{n})^{1-\theta}}{1 - (\frac{2}{n})^{1 - \theta}}, i \ge 3$$

接下来，我们只需要求出$r$，使其满足$\tilde{G}(n, \theta, r + 1) < u' \le \tilde{G}(n, \theta, r)$即可。

令$\tilde{G}(n, \theta, i) = u'$，有

$$
i = 1 + n (
	1 - \frac{1 - (\frac{2}{n})^{1-\theta}}{1 - \frac{\zeta(\theta, 2)}{\zeta(\theta, n)}} (1 - u)
)^{\frac{1}{1-\theta}}
$$

定义$\eta$:

$$\eta = \frac{1 - (\frac{2}{n})^{1-\theta}}{1 - \frac{\zeta(\theta, 2)}{\zeta(\theta, n)}}$$

定义$\alpha = \frac{1}{1 - \theta}$，则

$$i = 1 + n (1 - \eta (1 - u))^{\alpha} = 1 + n (\eta u - \eta + 1)^{\alpha}$$

由于$\tilde{G}$是关于$i$的减函数，所以$\tilde{G}(n, \theta, r + 1) < u' \le \tilde{G}(n, \theta, r)$等价于$r <= 1 + n (\eta u - \eta + 1)^{\alpha} < r + 1$，即

$$r = \lfloor 1 + n (\eta u - \eta + 1)^{\alpha} \rfloor$$

这就是论文里的公式。

## 评估

我们估计的$\tilde{G}(n, \theta, i)$在$i$比较大的时候比较接近$G(n, \theta, i)$，但当$i$很小时误差就会比较大。这里我们来测试一下误差究竟有多大。

为了减小浮点误差造成的影响，这里将$\tilde{G}$的形式变换成这样：

$$\tilde{G}(n, \theta, i) = \frac{n^{1 - \theta} - (i-1)^{1-\theta}}{n^{1 - \theta} - 2^{1 - \theta}}$$

```cpp
#include <cstdio>
#include <cmath>

constexpr size_t n = 20000000;
constexpr double theta = 0.99;
double zeta[n + 1];
double G(size_t i) {
	return (zeta[n] - zeta[i - 1]) / (zeta[n] - zeta[2]);
}
double G_tilde(double i) {
	//return (1 - pow((i - 1) / n, 1 - theta)) / (1 - pow(2 / n, 1 - theta));
	return (pow(n, 1 - theta) - pow(i - 1, 1 - theta)) /
		(pow(n, 1 - theta) - pow(2, 1 - theta));
}

void space(size_t num) {
	while (num) {
		num -= 1;
		putchar(' ');
	}
}

int main() {
	zeta[0] = 0;
	for (size_t i = 1; i <= n; ++i) {
		zeta[i] = zeta[i - 1] + pow((double)i, -theta);
	}

	size_t v[] = {3, 4, 5, 10, 100, 1000, 10000, 100000, 1000000, 10000000};
	printf("i\t\tG(i)\t\tG_tilde(i)\n");
	for (size_t i : v) {
		size_t ret = printf("%zu", i);
		space(16 - ret);
		ret = printf("%f", G(i));
		space(16 - ret);
		ret = printf("%f", G_tilde(i));
		putchar('\n');
	}

	return 0;
}
```

```text
i               G(i)            G_tilde(i)
3               1.000000        1.000000
4               0.980609        0.976770
5               0.966024        0.960231
10              0.922307        0.913352
100             0.782473        0.772490
1000            0.641863        0.633459
10000           0.498228        0.491684
100000          0.351273        0.346658
1000000         0.200898        0.198258
10000000        0.047020        0.046402
```

可以看到误差其实并不大。

为了进一步验证估计的准确性，我们接下来直接验证$F$的估计是否准确。

当$i \ge 3$时，有

$$\begin{aligned}
F(n, \theta, i)
=& \frac{\zeta(\theta, n) - G(n, \theta, i + 1) (\zeta(\theta, n) - \zeta(\theta, 2))}{\zeta(\theta, n)} \\
=& 1 - G(n, \theta, i + 1) (1 - \frac{\zeta(\theta, 2)}{\zeta(\theta, n)}) \\
\approx & 1 - \tilde{G}(n, \theta, i + 1) (1 - \frac{\zeta(\theta, 2)}{\zeta(\theta, n)}) \\
=& 1 - \frac{n^{1 - \theta} - i^{1-\theta}}{n^{1 - \theta} - 2^{1 - \theta}} (1 - \frac{\zeta(\theta, 2)}{\zeta(\theta, n)}) \\
=& \tilde{F}(n, \theta, i)
\end{aligned}$$

接下来我们对比$i \ge 3$时，$F$和$\tilde{F}$的差异：

```cpp
#include <cstdio>
#include <cmath>

constexpr size_t n = 20000000;
constexpr double theta = 0.99;
double zeta[n + 1];

double F(size_t i) {
	return zeta[i] / zeta[n];
}
double F_tilde(double i) {
	return 1 - (pow(n, 1 - theta) - pow(i, 1 - theta)) /
		(pow(n, 1 - theta) - pow(2, 1 - theta)) *
		(1 - zeta[2] / zeta[n]);
}

void space(size_t num) {
	while (num) {
		num -= 1;
		putchar(' ');
	}
}

int main() {
	zeta[0] = 0;
	for (size_t i = 1; i <= n; ++i) {
		zeta[i] = zeta[i - 1] + pow((double)i, -theta);
	}

	size_t v[] = {3, 4, 5, 10, 100, 1000, 10000, 100000, 1000000, 10000000};
	printf("i\t\tF(i)\t\tF_tilde(i)\n");
	for (size_t i : v) {
		size_t ret = printf("%zu", i);
		space(16 - ret);
		ret = printf("%f", F(i));
		space(16 - ret);
		ret = printf("%f", F_tilde(i));
		putchar('\n');
	}

	return 0;
}
```

```text
i               F(i)            F_tilde(i)
3               0.097466        0.100999
4               0.110890        0.116222
5               0.121653        0.128059
10              0.156545        0.164999
100             0.280381        0.289565
1000            0.409298        0.417032
10000           0.541446        0.547469
100000          0.676695        0.680943
1000000         0.815097        0.817527
10000000        0.956724        0.957292
```

误差也很小。

## 使用

```cpp
#include <iostream>
#include <cmath>
#include <random>
#include <cassert>

class ZipfianGenerator {
public:
	ZipfianGenerator(
		size_t n, double theta
	) : n_(n),
		alpha_(1 / (1 - theta)),
		zeta2_(1 + pow(2.0, -theta))
	{
		assert(n > 2);
		zetan_ = zeta2_;
		for (size_t i = 3; i <= n; ++i) {
			zetan_ += pow((double)i, -theta);
		}
		eta_ = (1 - pow(2.0 / n, 1 - theta)) / (1 - zeta2_ / zetan_);
	}
	template <typename E>
	size_t operator()(E &e) {
		std::uniform_real_distribution<> dis(0.0, 1.0);
		double u = dis(e);
		double uz = u * zetan_;
		if (uz < 1)
			return 1;
		if (uz < zeta2_)
			return 2;
		return 1 + (size_t)(n_ * pow(eta_ * u - eta_ + 1, alpha_));
	}
private:
	size_t n_;
	double alpha_;
	double zeta2_;
	double zetan_;
	double eta_;
};

int main() {
	std::random_device rd;
	std::mt19937 e(rd());
	size_t n = 20000000;
	ZipfianGenerator g(n, 0.99);

	for (size_t i = 0; i < n; ++i) {
		std::cout << g(e) << std::endl;
	}

	return 0;
}
```

## 注意事项

YCSB里的zipfian似乎默认是scrambled zipfian，它的item count被指定为了1e10，导致它生成的分布跟zipfian的理论分布不一致。建议不要用YCSB生成zipfian，而是用它的公式自己写一个。
