---
title: slab分配器
date: 2022-04-29 21:56:46
tags:
---

主要参考这本书：《Understanding the Linux virtual memory manager》，链接：<https://www.eecg.utoronto.ca/~yuan/teaching/archive/ece344_2017w/linux-vmm.pdf>，书上的Chapter 9就是讲slab分配器的。

注意这本书是2004的，很多参数可能已经过时了，这个博客会结合我自己的电脑硬件配置来讲。

## 层次结构

每个`cache`负责一种数据类型的分配。系统中所有的`cache`首尾相连构成一个`cache chain`。

每个`cache`中拥有一些slab。每个slab由连续的一或多页构成。在这些slab里的某个位置开始划分槽，然后object就在这些槽里分配。

每个`cache`里维护`slabs_full`、`slabs_partial`、`slabs_free`，分别代表槽已经全部被分配、槽部分被分配、槽没有被分配的slab。

## 着色

书上的第112页，9.1.5节就是将cache coloring的。

假如slab要分配的object比较大，那么slab里就有一些空间是没法分配的，那么就可以把每个slab里的object的起始分配点偏移不同数量的cache line长度，每种偏移称为一个color，这样不同color的object在映射到cache里时就会错开。假如object之间有padding，或者object内部有padding，那么这些padding可能跟其他color的object的非padding部分映射到组相联CPU cache里的同一组cache line里，这样这组cache line就能非padding部分被用上了。而且如果object里有hot data，那么这些hot data也会错开，从而映射到不同组的cache line。

比方说假如一个slab是4096字节，一个object是5*64=320字节，那么slab里就有4096 % 320 = 256字节是无法被分配的。假如一个cache line是64字节，然后要创建多个slab，那么就可以将第一个slab的object起始分配位置设置为0，第二个slab的设置成64，第三个slab的设置成128，第四个slab的设置成192，第五个slab的又设置成0，第六个slab的又设置成64，以此类推。假如object的结构如下：

```c
struct A {
    char hot_data[64];
    char padding[64];
    char cold_data[64*3];
};
```

那么偏移量分别为0、64、128、192的object的`hot_data`会分别映射到四组cache line里，这样就能充分利用cache了。

此外，slab内部首尾的一小段可以错开来，从而减少冲突。详见：<https://stackoverflow.com/a/57345687>

还有一种着色叫页着色(page coloring)，大意是将物理页根据映射到的cache line着色，然后尽量让邻近的虚拟页映射到不同颜色的物理页：<https://en.wikipedia.org/wiki/Cache_coloring>

## free list

slab里的free list是一个链表实现的栈，这样可以使得更晚被释放的object被更早分配，因为最近被释放的object很可能还在CPU cache里。具体实现看书里的9.2.4到9.2.6节。

## kmalloc, kfree

详见书上的9.4节。

`kmalloc`的函数定义在`include/linux/slab.h`里。

操作系统在全局维护了8B、16B、32B、……32MiB的slab allocator。当调用`kmalloc`的时候，其实就是选一个object size最小但是够用的slab allocator来分配。比如分配1到8字节都是用`kmalloc-8`这个slab allocator来分配，9到16字节用`kmalloc-16`来分配，17到32字节用`kmalloc-32`分配，以此类推。

`kfree`的函数定义在`mm/slab.c`里。首先调用`virt_to_cache`来找到对应的slab allocator，然后再在里面free掉这个object就好了。`virt_to_cache`的具体实现好像跟`folio`有关，没具体看。如果slab的尺寸确定，而且是对齐的话，那应该可以找到slab的起始位置。

## 参考

<https://www.linuxquestions.org/questions/linux-kernel-70/how-does-slab-coloring-maximizes-the-use-of-cache-lines-or-cache-rows-907564/>
