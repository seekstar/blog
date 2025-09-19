---
title: Transformer的个人理解
date: 2025-09-18 22:37:40
tags:
---

## Transformer工作原理

### 分词

文本进来之后，首先经过Tokenizer（分词器）分割成很多个token。每个token都会赋予一个从0开始的ID，用于后续索引。

然后通过一个embedding层，将token转换成一个多维向量，也叫做embedding。这个embedding层实际上是一个矩阵，大小是 `token总个数` * `隐藏层维度`。隐藏层维度就是embedding向量的长度。假如一个token的ID是233，那么就把这个矩阵的第233行拿出来作为这个token的embedding向量。这个embedding矩阵最开始是初始化成随机数（微调场景除外），在训练过程中通过反向传播之类的算法不断更新和调整。最终相似的token在向量空间中的距离会比较近。

通过embedding矩阵拿到token embedding之后，还要加上位置编码，这样模型才知道这个token跟其他token的相对位置。方便起见，我们仍然称加上了位置编码的向量为embedding。

把这些加上了位置编码的embedding一行一行叠在一起，就构成了最初始的输入矩阵X。X会依次通过模型的`N`个解码层。

### 残差连接 Residual Connection

为了防止层数过多时原始信息丢失，进而导致梯度消失的问题，现代模型通常采用残差连接的技术来连接各层以及子层。一个完整的Transformer解码层的大致流程如下。

```text
# 有些模型是Post-Layer Normalization (Post-LN)，先Attention再加，再LayerNorm。
# 不过现代Transformer一般用Pre-LN。所以下面展示的是Pre-LN

X: 输入矩阵

# 多头自注意力子层

# 层归一化
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
Q = X \times W_Q \\
K = X \times W_K \\
V = X \times W_V
$$

`Q`表示query，其中第i行可以理解成第i行对应的token正在寻找什么。

`K`表示key，其中第i行可以理解成第i行提供的信息的类型。

`V`表示value，其中第i行可以理解成第i行具体提供了什么信息。

然后计算自注意力

$$
\mathrm{Attention}(Q, K, V) = \mathrm{softmax}(Q \times K^T / \sqrt{d_k}) \times V
$$

softmax是把一个向量进行指数归一化，使其所有维度的总和为1。当softmax一个矩阵的时候，是每行独立归一的。

$d_k$是key向量的维度。由于softmax是指数归一化，而指数对绝对数值比较敏感，所以在softmax前先除以$\sqrt{d_k}$，防止点积结果过大，导致softmax函数的梯度消失。

$Q^{(l)} \times (K^{(l)})^T$ 相当于对Q和K的每行两两点积，求出每两行之间的相关度。第i行表示Q的第i行跟K的每行之间的相关度。每行独立进行softmax之后，再乘$V^{(l)}$，得到的结果里，第i行相当于是根据Q的第i行跟K的每行的相关度，对V的行做加权求和得到的值。也就是说，跟Q的第i行关系更密切的V的行在结果中的权重更高。

值得注意的是，在训练过程中为了防止看到未来的信息，需要用到掩码自注意力机制。不过我们这里只关注推理过程，所以不管这个。

### 多头自注意力 MultiHeadAttention

现代Tranformer架构的模型通常有多头注意力，每个头都有一套自己的$W_Q$, $W_K$, $W_V$，进而算出自己的`Q`, `K`, `V`和自注意的结果。假设有`n_heads`个头，每个头算出的自注意力的结果的维度是`d_head`，那么多头自注意力子层会将每个头的结果横向拼接起来，行数不变，维度变成`n_heads * d_head`。一般`n_heads * d_head`等于模型的维度`d_model`。结果再乘以矩阵$W^O$，融合各个头的信息。$W^O$的形状是(n_heads * d_head, d_model)。

### 前馈神经网络 FFN

$\mathrm{FFN}(x) = \text{ReLU}(X \times W_1 + b_1)\times W_2 + b_2$

主要作用是对信息进行非线性变换和特征提取。现代模型通常会把ReLU换成GELU。

### 输出next token

在经过所有的解码层之后，会得到一个跟原始输入矩阵大小相同的矩阵。我们只关注最后一行，将它取出，记为`hidden_states`。然后经过一个线性层：

logits = hidden_states $\times$ W_projection + b

其中 `W_projection`的大小是(d_model, vocab_size)，`d_model`是模型的隐藏维度，`vocab_size`是词汇表大小，也就是token总数。得到的`logits`是一个长度为`vocab_size`的向量。

然后进行归一化：

probabilities = softmax(logits)

然后我们就得到了下一个token的概率分布。

有多种方法从这个分布中选择一个作为next token。比如贪心搜索就是选择概率最高的那个，还有Top-k Sampling，只从概率最高的k个里采样。

### 迭代生成

拿到next token之后，将其加入到原始输入矩阵中，然后重新跑一遍上面的流程，又可以拿到next token。终止输出也是一个token，输出这个token之后就不再迭代了。
