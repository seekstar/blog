---
title: Intel SGX技术感性理解
date: 2021-11-29 11:53:17
tags:
---

Intel SGX论文：<https://eprint.iacr.org/2016/086.pdf>

区块链课上提到了。有点意思，这里记录一下我的个人感性理解，不保证正确。

Intel SGX(Software Guard Extensions)是一种TEE(Trusted Execution Environment)技术，目标是保证代码运行的时候的机密性和完整性。机密性是指数据（甚至代码？）不被其他进程读取。完整性是指运行的时候不会被其他进程干扰。

当操作系统本身是恶意的时，操作系统可以随意读取和修改进程的页。所以Intel SGX内部烧了公钥和私钥，公钥大家都知道，私钥烧在硬件内部，可能做了一些物理防护，使其很难被外部读取。代码要放到Intel SGX平台上跑前，先用Intel SGX的公钥把代码和数据以及自己的公钥加密，然后传给SGX。SGX用芯片内部的私钥解密之后，在一个外界无法访问的内存区域里执行，最后将结果打包，用传进来的公钥加密，然后跟输入和代码一起用自己的私钥签名。这样别人检查这个签名，就知道这个结果确实是在SGX上执行的。

这个在区块链上有应用。原始论文：[Cheng R, Zhang F, Kos J, et al. Ekiden: A platform for confidentiality-preserving, trustworthy, and performant smart contracts[C]//2019 IEEE European Symposium on Security and Privacy (EuroS&P). IEEE, 2019: 185-200.](https://arxiv.org/pdf/1804.05141.pdf)

这里简单说一下思路。区块链上的智能合约由于不能信任别的节点的执行结果，所以所有的全节点都要自己去执行一遍这个智能合约，会造成一定的算力浪费以及降低系统吞吐。但是有了Intel SGX之后，我们可以把智能合约放到有Intel SGX的机器上去执行，别的节点可以检查这个执行结果是不是真的是在Intel SGX上执行的，如果是，且信任Intel SGX的硬件是安全的，那别的节点都不用再执行了。大概是要给执行者一点奖励，激励大家贡献可信算力？
