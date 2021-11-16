---
title: Hexo支持Latex风格的公式编辑
date: 2021-11-16 20:06:13
tags:
---

### 方案一（推荐）：hexo-filter-mathjax + hexo-renderer-pandoc

hexo-filter-mathjax官方教程：<https://github.com/next-theme/hexo-filter-mathjax>

hexo-renderer-pandoc官方教程：<https://github.com/wzpan/hexo-renderer-pandoc>

先把所有其他hexo math有关的npm包卸掉，比方说这些：

```shell
npm un hexo-math --save
npm un hexo-renderer-markdown --save
```

然后安装hexo-filter-mathjax：

```shell
npm i hexo-filter-mathjax --save
```

然后安装pandoc: <https://pandoc.org/installing.html>

Debian系好像可以直接用apt安装：

```shell
sudo apt install pandoc
```

然后安装hexo-renderer-pandoc：

```shell
npm i hexo-renderer-pandoc --save
```

然后在想开启MathJax的博客前面加上```mathjax: true```，比如

```
---
title: On the Electrodynamics of Moving Bodies
categories: Physics
date: 1905-06-30 12:00:00
mathjax: true
---
```

如果懒得在每篇博客前面加上```mathjax: true```，就在```_config.yml```里加上

```yml
mathjax:
  every_page: true
```

这样所有博客都会自动使用MathJax。然后就可以像在Latex里面一样编辑公式了：

```tex
$\underset{theta}{\bowtie}$
$N^+ = \{x | x\in N \wedge x \ne 0\}$
```

$\underset{theta}{\bowtie}$

$N^+ = \{x | x\in N \wedge x \ne 0\}$

### 方案二：hexo-renderer-markdown

参考：
<https://github.com/wujun234/hexo-theme-tree/issues/14>

<https://github.com/niemingzhao/hexo-renderer-markdown>

```shell
npm un hexo-renderer-marked --save
npm i hexo-renderer-markdown --save
```

但是hexo-renderer-markdown好像有high severity vulnerabilities。而且仍然有些Latex公式不能正常显示。比如```\underset{theta}{\bowtie}```。而且单行公式里如果有```\}```的话公式就不能正常显示了。

### 方案三：hexo-math + hexo-renderer-marked

hexo-math官方教程: <https://github.com/hexojs/hexo-math>

```shell
npm i hexo-renderer-marked --save
npm i hexo-math --save
```

但是由于hexo-renderer-marked的原因，hexo-math的公式编辑只能是这种形式：

- katex公式

```
{% katex %}
c = \pm\sqrt{a^2 + b^2}
{% endkatex %}
```

$c = \pm\sqrt{a^2 + b^2}$

- mathjax公式

```
{% mathjax %}
\frac{1}{x^2-1}
{% endmathjax %}
```

$\frac{1}{x^2-1}$

### 失败的方案：hexo-math + hexo-renderer-kramed

教程：<https://zhuanlan.zhihu.com/p/108766968>。

公式会消失。这可能是因为hexo-renderer-kramed只支持到hexo 3，然后我用的是hexo 5。

hexo-renderer-kramed: <https://github.com/sun11/hexo-renderer-kramed>
