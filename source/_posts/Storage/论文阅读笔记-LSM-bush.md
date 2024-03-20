---
title: 论文阅读笔记-LSM-bush
date: 2024-03-20 23:32:59
tags:
---

首先介绍前置工作。

## 缩写

| 缩写 | 全称 |
| ---- | ---- |
| FPR | false positive rate |

## 符号

| 符号 | 含义 | 单位 |
| ---- | ---- | ---- |
| N | total data size | blocks |
| F | buffer size | blocks |
| L | number of levels | |
| M | 所有bloom filter的平均bits per bit | bits |
| p | sum of FPRs across all Bloom filters | |
| $p_i$ | Bloom filter FPR at Level $i$ | |
| T | base capacity ratio | |
| X | ratio growth exponential | |

## Bloom filter

假设bits per entry是$M$，那么false positive rate (FPR) 就是$e^{-M \cdot \ln^2 2}$

假如FPR是p，那么bits per entry就是$M = \frac{\ln \frac{1}{p}}{\ln^2 2}$

## Monkey

论文：<https://dl.acm.org/doi/pdf/10.1145/3035918.3064054>

假设总的FPR是$p$，LSM-tree的层数为L，size ratio是T。传统做法是每层的bloom filter的bits per entry都一样，这相当于把$p$均匀分在各层，即第$i$层的FPR为$\frac{p}{L}$，bits per entry是$M = \frac{\ln \frac{L}{p}}{\ln^2 2}$

然而bloom filter的FPR是随bit数$n$指数递减的，而层的大小是指数递增的，因此我们可以给较小的层分配更多bloom filter bits，这样可以在保持总的FPR不变的情况下减少内存使用量。

假设$p < 1$，第一层的FPR是$p_1$，那么Monkey会把第二层的FPR设置成$p_1 T$，第三层的FPR设置成$p_1 T^2$，以此类推。这样就有$p = p_1 (1 + T + T^2 + \cdots + T^{L-1}) = p_1 \frac{T^L - 1}{T-1}$，即$p_1 = p \frac{T-1}{T^L-1}$。

假设是leveling策略，那么第一层的bits per entry就是$M_1 = \frac{\ln \frac{T^L - 1}{(T-1)p}}{\ln^2 2} = O(\log \frac{T^{L-1}}{p})$。由于每层的FPR都比上一层大T倍，所以bits per entry比上一层少$\frac{\ln T}{\ln^2 2}$，然而总数据量比上一层大T倍，因此平均bits per entry是

$$\begin{aligned}
& \frac{M_1 + T(M_1 - \frac{\ln T}{\ln^2 2}) + T^2 (M_1 - 2 \frac{\ln T}{\ln^2 2}) + \cdots + T^{L-1} (M_1 - (L-1) \frac{\ln T}{\ln^2 2})}{1 + T + \cdots + T^{L-1}} \\
=& \frac{M_1 (1 + T + \cdots + T^{L-1}) - \frac{\ln T}{\ln^2 2} (T + 2 T^2 + \cdots + (L-1) T^{L-1})}{1 + T + \cdots + T^{L-1}} \\
=& M_1 - \frac{\ln T}{\ln^2 2} \cdot \frac{(T + 2 T^2 + \cdots + (L-1) T^{L-1})}{1 + T + \cdots + T^{L-1}}
\end{aligned}$$

假设$T + 2 T^2 + \cdots + (L-1) T^{L-1} = S$，那么

$$\begin{aligned}
S - TS &= T + T^2 + \cdots + T^{L-1} - (L-1)T^L = T\frac{T^{L-1} - 1}{T - 1} - (L-1)T^L \\
S &= \frac{(L-1)(T-1)T^L - T^L + T}{(T-1)^2}
\end{aligned}$$

平均bits per entry

$$\begin{aligned}
& M_1 - \frac{\ln T}{\ln^2 2} \cdot \frac{T - 1}{T^L - 1} S \\
=& M_1 - \frac{\ln T}{\ln^2 2} \cdot \frac{(L-1)(T-1)T^L - T^L + T}{(T^L - 1)(T-1)} \\
=& \frac{\ln \frac{T^L - 1}{(T-1)p}}{\ln^2 2} - \frac{\ln T}{\ln^2 2} \cdot \frac{(L-1)(T-1)T^L - T^L + T}{(T^L - 1)(T-1)} \\
=& O(\log \frac{T^{L-1}}{p}) - O(L \log T) \\
=& O(\log \frac{1}{p})
\end{aligned}$$

我们来代入数字检查一下：

```python
from math import *
T = 10
L = 4
p = 0.01
M = log((T**L - 1) / ((T-1)*p)) / log(2)**2 - log(T) / log(2)**2 * \
	((L-1)*(T-1)*T**L - T**L + T) / \
		((T**L - 1) * (T-1))
print('Average bits per entry: %f\n' %M)

M1 = log((T**L - 1) / ((T-1)*p)) / log(2)**2
Mi = M1
i = 1
M = 0
data = 0
p = 0
while True:
	M += Mi * T ** (i-1)
	data += T ** (i-1)
	p_i = exp(-Mi * log(2)**2)
	p += p_i
	print('Level %d, bits per entry: %f, false positive rate: %f' %(i, Mi, p_i))
	if i == L:
		break
	i += 1
	Mi -= log(T) / log(2)**2
M /= data
print('Average bits per entry: %f' %M)
print('Overall false positive rate: %f' %p)
```

```text
Average bits per entry: 10.334730

Level 1, bits per entry: 24.181732, false positive rate: 0.000009
Level 2, bits per entry: 19.389203, false positive rate: 0.000090
Level 3, bits per entry: 14.596674, false positive rate: 0.000900
Level 4, bits per entry: 9.804144, false positive rate: 0.009001
Average bits per entry: 10.334730
Overall false positive rate: 0.010000
```

而传统方法

```python
log(L / p) / log(2)**2
```

```text
12.470448459145366
```

## Dostoevsky

论文：<https://dl.acm.org/doi/pdf/10.1145/3183713.3196927>

大多数数据都在最后一层，因此大多数query都落在最后一层，但是每层产生的compaction I/O都是一样多的。因此将前面的层用tiering做compaction，有T个sorted run，最后一层用leveling，只有一个sorted run。这种策略叫做lazy leveling。

跟monkey一样，将总的FPR $p$分成$p_1 + p_1 T + p_1 T^2 + \cdots + p_1 T^{L-1}$。不同的是，用tiering的层有T个sorted run，每个sorted run的FPR是这层的FPR的$\frac{1}{T}$，因此跟之前leveling的分析结果相比前面的层的bits per entry要增加$\frac{\ln T}{\ln^2 2}$。不过没关系，由于每层的数据量是指数增大的，所以前面这些tiering层多出来的bits对平均bits per entry的影响很小：

$$
\frac{\ln T}{\ln^2 2} \cdot \frac{1 + T + \cdots + T^{L-2}}{1 + T + \cdots + T^{L-1}} = \frac{\ln T}{\ln^2 2} \cdot \frac{T^{L-1} - 1}{T^L - 1} = O(\frac{\log T}{T})
$$

## LSM-bush

论文：<https://dl.acm.org/doi/pdf/10.1145/3299869.3319903>

我们可以发现，增加某层的sorted run个数时，这一层的bits per entry是对数增大的，然而由于每层的数据量是指数增大的，所以增加上面的层的sorted run个数对平均bits per entry影响很小，而且还可以降低写放大。因此我们考虑从底层到最上层让sorted run个数指数增大。

$i < L$时，LSM-bush令第i层的sorted run个数$r_i = T^{X^{L-i-1}}$，论文里取的$X=2$。论文附录C里把每层的bloom filter的bit数算出来了，似乎跟Monkey的不太一样。

假设最后一层的size ratio是C，那么写放大等于$C + L - 1$。由于层数$L = O(\log_X \log_T \frac{N}{F})$，其中N是数据量，F是write buffer的大小，所以写放大等于$O(C + O(\log_X \log_T \frac{N}{F}))$。

论文里给出的point read的I/O复杂度是$O(1)$。
