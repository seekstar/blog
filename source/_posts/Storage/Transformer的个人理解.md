---
title: Transformer的个人理解
date: 2025-09-18 22:37:40
tags:
---

本人非AI方向，本文内容不保真。

## Transformer工作原理

### 分词

文本进来之后，首先经过Tokenizer（分词器）分割成很多个token。每个token都会赋予一个从0开始的ID，用于后续索引。

然后通过一个embedding层，将token转换成一个多维向量，也叫做embedding。这个embedding层实际上是一个矩阵，大小是 `token总个数` * `隐藏层维度`。隐藏层维度就是embedding向量的长度。假如一个token的ID是233，那么就把这个矩阵的第233行拿出来作为这个token的embedding向量。这个embedding矩阵在训练开始时通常随机初始化（但在微调场景下，会加载预训练模型的权重作为初始值），在训练过程中通过反向传播之类的算法不断更新和调整。最终相似的token在向量空间中的距离会比较近。

通过embedding矩阵拿到token embedding之后，还要加上位置编码，这样模型才知道这个token跟其他token的相对位置。方便起见，我们仍然称加上了位置编码的向量为embedding。

把这些加上了位置编码的embedding一行一行叠在一起，就构成了最初始的输入矩阵X。X会依次通过模型的`N`个解码层。

### 残差连接 Residual Connection

为了防止层数过多时原始信息丢失，进而导致梯度消失的问题，现代模型通常采用残差连接的技术来连接各层以及子层。一个完整的Transformer解码层的大致流程如下。

```text
# 有些模型是Post-Layer Normalization (Post-LN)，先Attention，再残差连接，再LayerNorm。
# 不过现代模型一般用Pre-LN。所以下面展示的是Pre-LN

X: 输入矩阵

# 多头自注意力子层

# 层归一化。按行归一化。
X' = LayerNorm(X)
# 多头自注意力
X' = MultiHeadAttention(X')
# 残差连接
X = X' + X

# 前馈神经网络子层（FFN）

# 层归一化
X' = LayerNorm(X)
# 前馈网络
X' = FFN(X')
# 残差连接
X = X' + X

X输出给下一层
```

直观上来讲，残差连接允许模型选择应该保留哪些原始信息，应该对哪些信息进行变化再传往下层。值得注意的是，由于残差连接，每层的输出矩阵跟它的输入矩阵都是一样大的，行数是输入token数，列数是模型维度`d_model`。模型维度要比较大，这样才能容纳足够多的信息。大型模型的维度可以上万。

下面介绍 MultiHeadAttention 和 FFN 的实现。

### 自注意力

对输入矩阵`X`，首先将它跟$W_Q$, $W_K$, $W_V$相乘，得到`Q`, `K`, `V`：

$$
\begin{aligned}
Q &= X \times W_Q \\
K &= X \times W_K \\
V &= X \times W_V
\end{aligned}
$$

`Q`表示query，其中第i行可以理解成第i行对应的token正在寻找什么。

`K`表示key，其中第i行可以理解成第i行提供的信息的类型。

`V`表示value，其中第i行可以理解成第i行具体提供了什么信息。

然后计算自注意力

$$\mathrm{Attention}(Q, K, V) = \mathrm{softmax}(Q \times K^T / \sqrt{d_k}) \times V$$

softmax是把一个向量进行指数归一化，使其所有维度的总和为1。当softmax一个矩阵的时候，是每行独立归一的。$y = \mathrm{softmax}(x)$ 相当于 $y_i = e^{x_i} / \sum_j e^{x_j}$

$d_k$是key向量的维度。由于softmax是指数归一化，而指数对绝对数值比较敏感，所以在softmax前先除以$\sqrt{d_k}$，防止点积结果过大，导致softmax函数的梯度消失。

$Q \times K^T$ 相当于对Q和K的每行两两点积，求出每两行之间的相关度。第i行表示Q的第i行跟K的每行之间的相关度。每行独立进行softmax之后，再乘$V$，得到的结果里，第i行相当于是根据Q的第i行跟K的每行的相关度，对V的行做加权求和得到的值。也就是说，跟Q的第i行关系更密切的V的行在结果中的权重更高。

值得注意的是，在训练过程中为了防止看到未来的信息，需要用到掩码自注意力机制。我们之后再详细介绍它。

### 多头自注意力 MultiHeadAttention

现代Tranformer架构的模型通常有多头注意力，每个头都有一套自己的$W_Q$, $W_K$, $W_V$，进而算出自己的`Q`, `K`, `V`和自注意的结果。假设有`n_heads`个头，每个头算出的自注意力的结果的维度是`d_head`，那么多头自注意力子层会将每个头的结果横向拼接起来，行数不变，维度变成`n_heads * d_head`。一般`n_heads * d_head`等于模型的维度`d_model`。结果再乘以矩阵$W^O$，融合各个头的信息。$W^O$的形状是(n_heads * d_head, d_model)。

### 前馈神经网络 FFN

$\mathrm{FFN}(x) = \text{ReLU}(X \times W_1 + b_1)\times W_2 + b_2$

主要作用是对信息进行非线性变换和特征提取。现代模型通常会把ReLU换成GELU。

值得注意的是，这里面$b_1$是一个向量，在这个语境下，矩阵加一个向量实际上是矩阵的每行都加这个向量。

### 输出next token

在经过所有的解码层之后，会得到一个跟原始输入矩阵大小相同的矩阵。我们只关注最后一行，将它取出，记为`hidden_states`。然后经过一个线性层（语言模型头，LM Head）：

logits = hidden_states $\times$ W_projection + b

其中 `W_projection`的大小是(d_model, vocab_size)，`d_model`是模型的隐藏维度，`vocab_size`是词汇表大小，也就是token总数。得到的`logits`是一个长度为`vocab_size`的向量。

然后进行归一化：

probabilities = softmax(logits)

然后我们就得到了下一个token的概率分布。

有多种方法从这个分布中选择一个作为next token。比如贪心搜索就是选择概率最高的那个，还有Top-k Sampling，只从概率最高的k个里采样。

### 迭代生成

拿到next token之后，将其加入到原始输入矩阵中，然后重新跑一遍上面的流程，又可以拿到next token。终止输出也是一个token，输出这个token之后就不再迭代了。

### 因果掩码（Causal Mask）

看了上面的分析，可能会认为训练过程就是先输入[A]，预测下一个，算loss，然后更新权重，再输入[A, B]，算loss，更新权重，再输入[A, B, C]，算loss，更新权重。但是这样显然太低效了，一个长度为`n`的序列要计算`n`次。事实上，在最早的《Attention is all you need》论文里，作者就已经提出了因果掩码来解决这个问题。

我们先回顾无因果掩码的自注意力计算方式：

$$\mathrm{Attention}(Q, K, V) = \mathrm{softmax}(Q \times K^T / \sqrt{d_k}) \times V$$

在这个公式里，$Q \times K^T$得到的是任意两个token之间的相关度，并根据相关度来对V进行加权求和。这样的话，前面的token对应的结果里会出现后面的token对应的value。因果掩码旨在避免这种情况，让前面的token不要看到后面的token的value。所以我们构造掩码矩阵`M`，假设token个数为`n`，那么它是形状为`(n, n)`的矩阵：

- M[i, j] = 0, j <= i
- M[i, j] = -$\infty$, j > i

自注意力计算公式变成了：

$$\mathrm{Attention}(Q, K, V) = \mathrm{softmax}(Q \times K^T / \sqrt{d_k} + M) \times V$$

这样，在进行softmax前，矩阵里j > i的部分就变成了$-\infty$，softmax之后就变成了0。这样我们就可以保证在最后的结果里一个token对应的行只会包含前面的行的value。

采用因果掩码之后，我们可以得到一个很美妙的性质：**最后一个编码层的输出的第i行只跟前i个输入的token相关**。要证明这个性质，我们只需要证明原始输入增加一个token之后，最终结果里前面的token对应的行不变，只是在后面增加了一行。

新增一个token之后，原始输入矩阵新增了一行。

由于归一化是按行归一化，所以结果跟以前相比也只是多了一行。

在自注意力的计算过程中，我们假设输入矩阵为$\begin{pmatrix}X_0 \\ x\end{pmatrix}$，其中$X_0$是原来的矩阵，$x$是新的行。那么$\begin{pmatrix}X_0 \\ x\end{pmatrix} \times W = \begin{pmatrix} X_0 \times W \\ x \times W \end{pmatrix}$，可以看到跟$X_0 \times W$相比只是多了一行$x \times W$。所以算出的$Q, K, V$相比原来的结果也只增加了一行。

接下来考虑使用`Q, K, V`计算自注意力（含因果掩码）的过程：

$$\mathrm{Attention}(Q, K, V) = \mathrm{softmax}(Q \times K^T / \sqrt{d_k} + M) \times V$$

$Q \times K^T / \sqrt{d_k}$不仅增加了一行，也增加了一列。但是由于因果掩码的存在，最后增加的一列只会影响最终结果里的最后一行，前面的行仍然保持不变。所以自注意力的计算结果仍然只是在最后增加了一行。

多头的结果横着拼接起来之后也是只多了一行。乘以矩阵$W^O$之后还是只多了一行。

显然，残差连接的结果也只增加一行。所以如果输入增加一行，那么多头自注意力子层的结果也只增加一行。

FFN的计算过程中，矩阵的乘法和加法的结果也是只增加一行。ReLU和GELU都是逐元素的激活函数，结果也是只增加一行。所以FFN的结果也是只增加一行。

由于层归一化、多头、FFN、残差连接的结果都是只增加一行，所以输入矩阵增加一行之后，解码层的输出也是只增加一行。所以整个Transformer模型增加一个token的输入之后，最终输出的矩阵也是只增加一行，之前的行不变。

得证。

因此，我们可以认为第1行是对第2个token的预测，第2行是对第3个token的预测，以此类推。我们拿到token i在预测中的概率 $p_i$，算出它的交叉熵损失 (Cross-Entropy Loss)：$\mathrm{loss}_i = -\log(p_i)$

整个序列的损失函数一般取所有token的交叉熵损失的平均值：

$\mathrm{loss} = \sum_i \mathrm{loss}_i / n = -\sum_i \log(p_i) / n$

然后根据这个整个序列的损失值来进行反向传播，更新整个模型的参数。因为如果只考虑单个token的话，总是存在不确定性的，把loss降低到0没有什么意义，甚至还会导致模型过拟合。但是如果考虑一整个序列的loss，将它尽可能变小至少可以防止某个token在预测中的概率接近0，虽然仍然有过拟合的风险，但相比降低单token的loss已经好很多了。

## KV Cache

根据我们在`因果掩码`中的讨论，输入增加一个token，所有中间状态都只增加了一行。因此一个很自然的想法就是把这些中间状态缓存下来，这样每次生成一个token之后就不需要重新把这些中间状态算出来，而是直接计算新增的那一行。但是缓存所有中间状态太耗存储空间了，因此我们这里分析哪些中间状态在新增了一个token之后的计算过程中起到了作用，这样我们只需要缓存这些中间状态即可正常预测下一个token。

我们从后往前推导。残差连接输出的最后一行只跟输入的最后一行有关，因此不需要缓存残差连接的输入。

矩阵增加一行时：$\begin{pmatrix}X_0 \\ x\end{pmatrix} \times W = \begin{pmatrix} X_0 \times W \\ x \times W \end{pmatrix}$，输出的矩阵的最后一行用$x\times W$即可计算得到，所以我们也不需要缓存原来的矩阵。矩阵的加法，ReLU，GELU，输出的最后一行都只跟最后一行有关。所以FFN的输出的最后一行也只跟输入的最后一行有关，不需要缓存输入的矩阵。

层归一化LayerNorm是按行归一化，所以输出的最后一行也只跟输入的最后一行有关。
所以前馈神经网络子层输出的最后一行只跟输入的最后一行有关。

接下来考虑多头自注意力子层。残差连接和层归一化我们前面讨论过了。多头的结果是每个头的结果横着拼起来再乘以$W^O$，所以多头的结果的最后一行只跟每个头的结果的最后一行有关。现在考虑每个头的计算过程：

$$\mathrm{Attention}(Q, K, V) = \mathrm{softmax}(Q \times K^T / \sqrt{d_k} + M) \times V$$

结果的最后一行需要用到$V$和$\mathrm{softmax}(Q \times K^T / \sqrt{d_k} + M)$的最后一行。由于softmax是按行的，所以只需要$V$和$Q \times K^T$的最后一行，而$Q \times K^T$的最后一行由Q的最后一行和$K$决定。所以多头结果的最后一行只需要$Q$的最后一行，$K$，以及$V$。

综上所述，我们只需要缓存$K$和$V$即可在新增一个token之后算出下一个token的预测。这就是KV Cache。

### Prefill

考虑这样一个情形：用户给出prompt，然后模型在后面进行next token的预测。根据我们上面的分析，我们只需要得到prompt的K和V即可开始预测。而这个得到prompt的K和V的过程就叫做prefill。

如果是没见过的prompt，那么我们就要依照完整的transformer算法逐层算出K和V。需要注意的是，除了最后一层，前面的层不仅要算K和V，还要计算Q和自注意力，这样才能得到下一层的完整输入用来算出下一层的K和V。这个过程非常消耗算力，复杂度是 $O(n^2)$。所以如果一个prompt经常被使用，那么我们可以考虑把它的K和V存下来，下次看到了就可以直接把对应的K和V读出来用。

## Batch

计算一段prompt的K和V时，如果prompt比较短，那么可能不能充分利用GPU的并行度。因此现代推理系统普遍采用动态批处理技术，将差不多时间到达的请求中长度相近的进行padding，让它们等长，然后凑成batch。现代深度学习框架对这种batch的矩阵运算进行了高度优化，从而可以更高效地利用GPU资源。

## NanoFlow

论文：<https://arxiv.org/pdf/2408.12757>

GitHub: <https://github.com/efeslab/Nanoflow>

这篇论文注意到Prefill的过程是计算密集型的，但是推理的过程却是memory-bound的，因为推理的时候很多向量乘以矩阵的操作，实际上相当于把矩阵读了一遍，而每次产生一个新的token都要把模型里的矩阵都读一遍，因此会消耗很多显存带宽。

因此这篇论文旨在想办法让memory-bound的过程跟compute-bound的过程在时间上overlap，从而可以充分利用GPU的资源。
