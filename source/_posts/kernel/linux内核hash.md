---
title: linux内核hash
date: 2020-02-23 23:08:02
---

linux内核API文档：
<https://www.kernel.org/doc/htmldocs/kernel-api/index.html>
带搜索的：
<https://www.kernel.org/doc/html/latest/>

参考：<https://security.stackexchange.com/questions/11839/what-is-the-difference-between-a-hash-function-and-a-cryptographic-hash-function>
哈希有两种：加密哈希和非加密哈希。
加密哈希的目标是通过加密哈希的得到的哈希值很难逆推得到原始值，而非加密哈希的目标仅仅是减小哈希冲突。

# 加密哈希
linux内核官方文档中有一个例子：
<https://www.kernel.org/doc/html/latest/crypto/api-samples.html>
```c
struct sdesc {
    struct shash_desc shash;
    char ctx[];
};

static struct sdesc *init_sdesc(struct crypto_shash *alg)
{
    struct sdesc *sdesc;
    int size;

    size = sizeof(struct shash_desc) + crypto_shash_descsize(alg);
    sdesc = kmalloc(size, GFP_KERNEL);
    if (!sdesc)
        return ERR_PTR(-ENOMEM);
    sdesc->shash.tfm = alg;
    return sdesc;
}

static int calc_hash(struct crypto_shash *alg,
             const unsigned char *data, unsigned int datalen,
             unsigned char *digest)
{
    struct sdesc *sdesc;
    int ret;

    sdesc = init_sdesc(alg);
    if (IS_ERR(sdesc)) {
        pr_info("can't alloc sdesc\n");
        return PTR_ERR(sdesc);
    }

    ret = crypto_shash_digest(&sdesc->shash, data, datalen, digest);
    kfree(sdesc);
    return ret;
}

static int test_hash(const unsigned char *data, unsigned int datalen,
             unsigned char *digest)
{
    struct crypto_shash *alg;
    char *hash_alg_name = "sha1-padlock-nano";
    int ret;

    alg = crypto_alloc_shash(hash_alg_name, 0, 0);
    if (IS_ERR(alg)) {
            pr_info("can't alloc alg %s\n", hash_alg_name);
            return PTR_ERR(alg);
    }
    ret = calc_hash(alg, data, datalen, digest);
    crypto_free_shash(alg);
    return ret;
}
```
下面根据我自己的理解解释这段代码。

## 加密handler：struct crypto_shash
### 生成
crypto_alloc_shash：根据指定的哈希算法，生成handler，并返回其指针。
原型：
```c
struct crypto_shash *crypto_alloc_shash(const char *alg_name, u32 type,
					u32 mask);
```
alg_name: algorithm name，哈希算法名称
type和mask一般都是0。~~其实我也不清楚~~

### 销毁
crypto_free_shash: 销毁由crypto_alloc_shash生成的handler。
```c
static inline void crypto_free_shash(struct crypto_shash *tfm);
```

## struct shash_desc
```c
struct shash_desc {
	struct crypto_shash *tfm;
	u32 flags;

	void *__ctx[] CRYPTO_MINALIGN_ATTR;
};
```
tfm: 加密handler
ctx: 空数组的首地址，相当于汇编里的一个标号，指向结构体的后一个字节。
这个结构体可能会跟一段buffer一起被申请，而ctx就相当于这段buffer的首地址，所以为了防止访问buffer时出现对齐错误，需要给ctx加上属性CRYPTO_MINALIGN_ATTR。
CRYPTO_MINALIGN_ATTR的含义是通过可能的字节填充，使得ctx是以最大的对齐标准对齐的，防止出现对齐错误。例如在我的机器上，CRYPTO_MINALIGN_ATTR的含义是强制以64位对齐。

## struct sdesc
加密handler的第二层封装。我个人觉得上一层封装`struct shash_desc`已经可以用了。但是既然官方文档都自定义了一个结构体，就……
```c
struct sdesc {
    struct shash_desc shash;
    char ctx[];
};
```
ctx作为后面跟着的buffer的首地址。由于struct shash_desc里已经进行过对齐，所以后面跟着的buffer的首地址一定是对齐的。

### 生成
```c
static struct sdesc *init_sdesc(struct crypto_shash *alg)
{
    struct sdesc *sdesc;
    int size;

    size = sizeof(struct shash_desc) + crypto_shash_descsize(alg);
    sdesc = kmalloc(size, GFP_KERNEL);
    if (!sdesc)
        return ERR_PTR(-ENOMEM);
    sdesc->shash.tfm = alg;
    return sdesc;
}
```
crypto_shash_descsize(alg): 得到这个加密算法需要的buffer大小。

struct shash_desc的大小加上buffer大小就是总共需要申请的内存大小`size`。

kmalloc: 申请小于一页的内存。其中GFP_KERNEL表示申请正常的内核RAM，可以睡眠。参考：<https://www.kernel.org/doc/htmldocs/kernel-api/API-kmalloc.html>

ERR_PTR: 把错误码变成指针。戳这篇文章：
<https://blog.csdn.net/yaozhenguo2006/article/details/7967547>
ENOMEM: error, no memory

### 销毁
kfree其内存即可

## 计算哈希值
```c
int crypto_shash_digest(struct shash_desc *desc, const u8 *data,
			unsigned int len, u8 *out);
```
其中desc后面一定要有足够长的buffer（前面用crypto_shash_descsize保证了）
out就是生成的哈希值。

# 非加密哈希
一种非常快的哈希质量很好的非加密哈希函数为xxHash系列（xxh32和xxh64）
在`linux/xxhash.h`中xxh32的声明如下：
```c
uint32_t xxh32(const void *input, size_t length, uint32_t seed);
```
用法是显然的。
benchmarks：<https://cyan4973.github.io/xxHash/>
