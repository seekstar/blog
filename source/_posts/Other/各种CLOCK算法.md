---
title: 各种CLOCK算法
date: 2021-10-14 22:22:16
---

这篇文章的背景是操作系统里的页缓冲。

LRU要求每次访问某个页的时候都进入trap，由操作系统把这个页放到栈顶。显然这是不能接受的。

所以一般采用CLOCK算法或者其变种，其特点是在hit的时候，只需要由硬件执行一个很简单的操作（通常是设置访问位），把这次访问记录下来即可。然后在合适的时机，由操作系统去看这些访问记录，把冷的页替换掉。

# 朴素CLOCK算法
一圈页，一个指针指向某页，要替换某页时，看指向的那页的访问位是不是1，如果不是就将这页替换掉，如果是则置0，然后移到下一页继续看。

# GCLOCK
论文：
[Sequentiality and Prefetching in Database Systems ](https://www-inst.eecs.berkeley.edu//~cs266/sp10/readings/smith78.pdf)
[ Analysis of the generalized clock buffer replacement scheme for database transaction processing](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.452.9699&rep=rep1&type=pdf)

给每页一个counter，当hit的时候增加它的值，当指针扫过的时候减这个值，减到0就可以替换掉了。好处是可以保留更多的历史访问信息，更精准地把很少访问的页找出来。
 
# Two-Handed Clock
朴素的Clock算法的问题在于，如果访问很多，而过了很久才需要替换某页时，会发现所有的页的访问位都是1，这样就退化到FIFO了。这是保存了太多历史信息导致的。所以思路就是周期性清除历史信息。Two-Handed Clock就是这种算法，它有两个指针，一个fronthand，一个backhand，这两个指针之间的距离（好像）恒定。fronthand负责清除其指向的页的访问位，然后backhand看这个访问位是不是又被置1了，如果是，那说明这个页访问挺频繁的，就跳过它，否则就将这个页free掉。当空闲空间少时，就把指针扫描的速度调快，这样能识别出更多访问不频繁的数据，当空闲空间多时，就把指针扫描速度调慢，只把超级冷的块free掉。当空闲空间超过超过阈值lotsfree后，就停下来不扫描了。

相关文献：

[The design and implementation of the 4.3BSD UNIX operating system](https://dl.acm.org/doi/abs/10.5555/61656)
好像是本书

[4.3 BSD Virtual Memory Management](http://www.xilef-software.e8u.de/sites/default/files/store/bsd43vmm/bsd43vmm.pdf)
（Figure 10第17行，goto loop之后，backhand没有移动，这是不是会导致两个指针的距离改变？）

# CAR
论文：[CAR: Clock with Adaptive Replacement](https://www.usenix.org/legacy/publications/library/proceedings/fast04/tech/full_papers/bansal/bansal.pdf)

看起来很复杂的样子

# CLOCK-Pro
论文：<https://www.usenix.org/legacy/events/usenix05/tech/general/full_papers/jiang/jiang.pdf>

![在这里插入图片描述](https://img-blog.csdnimg.cn/693da5f78d5e447ba3e17ecfab615252.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBAc2VhcmNoX3N0YXI=,size_17,color_FFFFFF,t_70,g_se,x_16)

将页分为Hot页，Cold页，所有Hot页都留在内存里，Cold页中，留在内存里的页在图中带有阴影，被换出内存的页在图中没有阴影。图中，打勾表示这个页的访问位为1。令m表示内存中能装下的总页数。为了避免列表过大，我们限制列表中最多有m个不在内存里的cold页。

跟LRU一样，CLOCK-Pro使用recency的概念，距离上次使用的时间越长，recency越高，但是由于我们不能像LRU那样在每次访问页面的时候都去维护这个recency，所以这个recency实际上是通过指针转动来估计的。CLOCK-Pro的基本思想是给每个刚进来的cold页一个测试周期，如果这个页在测试周期中被访问了，那就把这个页变成hot页，否则就把这个页移出列表。我们允许把仍然在测试周期中的cold页换出内存，但是它仍然停留在列表中，直到测试周期结束。

我们设置三个指针：HAND_hot、HAND_cold、HAND_test。HAND_hot指向recency最高的hot页，HAND_cold指向recency最高的在内存里的cold页，HAND_test指向recency最高的处于测试周期的cold页。HAND_hot背面的那个页是recency最小的页，从该页开始逆时针看，这些页的recency逐渐增大，到HAND_hot指向的那个页，recency最大。将HAND_hot背面的那个页称为list head，将HAND_hot指向的那个页称为list tail。

HAND_cold是用来将某个cold页换出的。如果HAND_cold指向的页的访问位是0，就把它换出，然后如果它不在测试周期，就把它移出列表，如果在测试周期，就把它留在列表里。如果HAND_cold指向的页的访问位是1，就把这个页移动到HAND_hot指针的背后，即插入到list head，即将这个页的recency标记为最小（要不要把访问位清0呢？）。此外，如果这个页的访问位为1且在测试周期中，那么就把它变成hot页，并且让HAND_hot指针移动，来让某个hot页变成cold页。
（HAND_cold指向的页是hot页的时候怎么办？跳过吗？）

HAND_hot采取动作时，如果其指向hot页，并且其访问位为0，那就把它变成cold页，但是如果其访问位为1，就把访问位清0，然后跳过它。如果其指向cold页，就终止其测试周期，并且如果它不在内存中时将其从列表中移出（也就是说当HAND_test）用。

如果不在内存中的页数超过了m，那么就需要HAND_test采取行动了。（HAND_test好像会跳过hot页）HAND_test会终止指向的cold页的测试周期，然后如果其不在内存里，就把它移出列表。

所以总的流程是，如果有一个page fault，那么这个page肯定是个cold page，因为hot page不会被换出。首先我们移动HAND_cold来把一个页换出。如果这个faulted page不在列表中，那么我们就把它放到list head，也就是插入到HAND_hot背后，并且标记其处于测试周期。如果这个faulted page在列表中，那么我们直接把它变成hot页，并且移动到list head，然后移动HAND_hot来将一个hot页变成cold页。此外，由于我们之前把一个cold页换出了，这可能会增加不在内存中的cold页的数目，如果这个数目大于m，那就通过移动HAND_test减少之（这一步是在移动HAND_cold之后就做，还是到最后做？）。

**猜一下作者的心路历程**

不管是LRU，还是朴素的CLOCK，页被换出之后都不再跟踪了，这样就导致recency比较低的块不敢换出去。但是实际上，recency低不代表马上就会reuse。所以就要把换出的页也保留在这个环形列表里，然后recency低的页也可以大胆换出，然后如果发现其实很快就reuse了，就反悔，把它变成hot页，不再轻易换出。但是在列表中的cold页又不一定是recency很低的页，如果一个很老的不在内存里的cold页又被访问了，那也不能随便将其设置为hot页，所以就引入测试周期的概念，其实就是用来查看在给定的一段时间内，这个页能不能被访问两次，能的话就变成hot页。

**我的一些问题**

论文里的$m_c$到底是个啥？？？是在内存里的cold页的最大数目吗？可是前面的叙述里也没看到这个值有什么作用啊。

论文里只有在一个页刚刚进入列表时才开启测试周期，那这样的话，如果一个hot页变成了cold页，那岂不是永远都变不回hot页了？我觉得将页插入到list head的时候（比如hot页变成cold页，或者HAND_cold指针指向的cold页的访问位是1，但是不在测试周期的时候）同时开启测试周期应该会更合理一些。

感觉这个论文少了很多实现细节，看得迷迷糊糊的。
