---
title: clflush、clflushopt、clwb、pcommit、ntstore
date: 2020-09-07 01:21:41
tags:
---

参考：
<https://danluu.com/clwb-pcommit/>    (14年文档)
<https://blog.csdn.net/maokelong95/article/details/81362837>
<https://zhuanlan.zhihu.com/p/135188922?utm_source=zhihu&utm_medium=social&utm_oi=620920856499720192>

clflush: 把cache line刷回内存，并且让cache line失效。只能串行执行。
clflushopt: 功能同clflush，但是不同缓存行可以并发执行。
clwb: 除了写回后不让cache line失效，其他同clflushopt。
pcommit: 把所有落在持久化内存区域的store持久化。（已弃用？）
ntstore: 绕过CPU cache，直接写到内存。一般用于写完就不管的情况，可以防止污染cache。

把内容写回NVMM的一般步骤：
```c
clwb(addr);
sfence();
PCOMMIT();	// 已弃用？
sfence();
*addr = balabala;
```

clflushopt一般用来flush一大段地址的缓存行，Linux内核中已经给出了对应的函数：
```c
#define mb() 	asm volatile("mfence":::"memory")

static void clflush_cache_range_opt(void *vaddr, unsigned int size)
{
	const unsigned long clflush_size = boot_cpu_data.x86_clflush_size;
	void *p = (void *)((unsigned long)vaddr & ~(clflush_size - 1));
	void *vend = vaddr + size;

	if (p >= vend)
		return;

	for (; p < vend; p += clflush_size)
		clflushopt(p);
}
/**
 * clflush_cache_range - flush a cache range with clflush
 * @vaddr:	virtual start address
 * @size:	number of bytes to flush
 *
 * CLFLUSHOPT is an unordered instruction which needs fencing with MFENCE or
 * SFENCE to avoid ordering issues.
 */
void clflush_cache_range(void *vaddr, unsigned int size)
{
	mb();
	clflush_cache_range_opt(vaddr, size);
	mb();
}
EXPORT_SYMBOL_GPL(clflush_cache_range);
```
