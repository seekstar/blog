---
title: LCT感性理解
date: 2021-11-10 18:04:15
tags:
---

LCT是用来维护有根树森林的，要支持以下操作。

- make-tree(v)：让节点v单独变成一个有根树。

- link(v, w)：把v挂在w上。

- cut(v, w)：让v不再是w的子节点。

- find-root(v)：找到v所在的树的根。

find-root(v)的时候，如果直接用原来的有根树，那就要一个一个往上跳，直到跳到根节点。我们考虑采用树链剖分的方式，将这棵有根树剖成一条一条竖着的链，如果每条链都可以快速求出其最上面的节点的话，那就可以沿着这些链快速跳到根。

如果采用轻重链剖分的方式，那么树就必须是静态的，而且复杂度是$O(\log^2(n))$。其实如果这棵有根树是完全平衡的，那其实树高就是$O(\log(n))$的，那显然跳跃的时间复杂度就是$O(\log(n))$的。轻重链剖分无法达到这个复杂度的根源在于，虽然每条链组成的小树是平衡的，但是这是局部的平衡，这棵小树的形态并没有根据其他小树来做调整。

LCT是一种对有根树进行动态剖分的方法，可以达到全局平衡的效果，从而实现$O(\log n)$的复杂度。LCT里，每个节点最多有一个preferred child（也可以没有），对应的边为preferred edge。这样，由preferred edge连接起来的点就构成一条竖着的链。access(v)时，从v节点一直往上直到根节点的路径上的所有边都变成preferred edge，然后跟这些edge共享同一个父节点的preferred edge变成unpreferred edge。这样，在find-root(v)的时候，只要access(v)，然后找到v到根的这条链的最上面的节点即可找到根节点。

可以看到，这些链经常要进行拆分重组，所以使用splay来维护这些链，在原树中越高层的节点在splay里越小（其实反过来应该也可以）。这样，cut和link也成为了可能。cut(v, parent(v))时，同样先access(v)，这时v在splay里是最大的，而且是根，所以直接把v从splay里断开即可。link(v, w)时，先access(v)和access(w)，由于v是要挂上去的子树的根，所以其在所在的splay里是最小的节点，access(v)之后就变成了splay的根，而且没有左子树。access(w)之后，w同样成为了它到根的链上的splay的根，然后就可以直接把w挂到v的splay的左子树上。

看起来好像是$O(\log^2(n))$的复杂度。有趣的是，摊还分析的结论是所有操作的复杂度都是$O(\log(n))$的（怎么分析的我也看不懂）。

实际上，根据这篇文章：[SPOJ375 QTREE 解法的一些研究](https://jeffswt.org/blog/bzoj2002/qtree.pdf)，如果我们在轻重链剖分中，把维护重链的线段树换成splay，那由于splay会自适应地减少经常被访问的节点的高度，所以也能实现全局平衡的效果，复杂度同样为$O(\log n)$。但是由于splay的常数比线段树大得多，所以实际效果可能还比线段树的$O(\log^2 n)$的版本慢。所以这篇论文里提出了一个静态的可以实现全局平衡的重链维护方案，实现了$O(\log n)$的复杂度，而且常数也小。~~不过我没看懂。~~

如何实现可以看这里：[LCT总结——概念篇+洛谷P3690[模板]Link Cut Tree(动态树)（LCT，Splay）](https://www.cnblogs.com/flashhu/p/8324551.html#!comments)

一些能用LCT做的题：[LCT总结——应用篇（附题单）（LCT）](https://www.cnblogs.com/flashhu/p/9498517.html)

维护原树子树上的信息可以用LCT的升级版——top tree：

[Link-Cut Tree(LCT)&TopTree讲解](https://www.cnblogs.com/Khada-Jhin/p/9743397.html)

[<del>noip退役选手的another扯淡</del>Top tree 相关东西的理论、用法和实现](https://negiizhao.blog.uoj.ac/blog/4912)

参考文献：

[Sleator D D, Tarjan R E. A data structure for dynamic trees[J]. Journal of computer and system sciences, 1983, 26(3): 362-391.](https://www.sciencedirect.com/science/article/pii/0022000083900065)

<https://en.wikipedia.org/wiki/Link/cut_tree>
