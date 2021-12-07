---
title: Bad or missing usercopy whitelist? Kernel memory overwrite attempt detected to SLUB object
date: 2020-11-11 14:59:45
---

Linux内核有一个usercopy whitelist机制，只允许这里面的region来做usercopy。如果是用kmem_cache_create申请的kmem_cache申请的内存空间来copy to user或者copy from user，那么就会报这个错。这时要用kmem_cache_create_usercopy，来将申请的区域加入到usercopy whitelist中。


```
/**
 * kmem_cache_create_usercopy - Create a cache with a region suitable
 * for copying to userspace
 * @name: A string which is used in /proc/slabinfo to identify this cache.
 * @size: The size of objects to be created in this cache.
 * @align: The required alignment for the objects.
 * @flags: SLAB flags
 * @useroffset: Usercopy region offset
 * @usersize: Usercopy region size
 * @ctor: A constructor for the objects.
 *
 * Cannot be called within a interrupt, but can be interrupted.
 * The @ctor is run when new pages are allocated by the cache.
 *
 * The flags are
 *
 * %SLAB_POISON - Poison the slab with a known test pattern (a5a5a5a5)
 * to catch references to uninitialised memory.
 *
 * %SLAB_RED_ZONE - Insert `Red` zones around the allocated memory to check
 * for buffer overruns.
 *
 * %SLAB_HWCACHE_ALIGN - Align the objects in this cache to a hardware
 * cacheline.  This can be beneficial if you're counting cycles as closely
 * as davem.
 *
 * Return: a pointer to the cache on success, NULL on failure.
 */
struct kmem_cache *
kmem_cache_create_usercopy(const char *name,
		  unsigned int size, unsigned int align,
		  slab_flags_t flags,
		  unsigned int useroffset, unsigned int usersize,
		  void (*ctor)(void *))
```
其中offset是指region相对于申请的内存的首地址的偏移量。如果整个区域都是，那么就设置为0。
