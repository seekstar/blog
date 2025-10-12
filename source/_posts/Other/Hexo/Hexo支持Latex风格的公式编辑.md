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

然后在想开启MathJax的博客前面加上`mathjax: true`，比如

```text
---
title: On the Electrodynamics of Moving Bodies
categories: Physics
date: 1905-06-30 12:00:00
mathjax: true
---
```

如果懒得在每篇博客前面加上`mathjax: true`，就在`_config.yml`里加上

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

然后给pandoc传入这些参数：

```yml
pandoc:
  args: [
    # I don't know why but mathjax won't work without hexo-filter-mathjax or --mathjax
    '--mathjax',
    # -smart: 不把引号渲染成带方向的引号。
    # +backtick_code_blocks: 代码块
    # +implicit_figures: 防止在图片后面将方括号里的东西作为caption。<https://github.com/wzpan/hexo-renderer-pandoc/issues/34>
    # +gfm_auto_identifiers: 用github的方式生成header之类的identifier
    # +intraword_underscores: 不把下划线用来强调。强调用星号。
    # +hard_line_breaks: 两行之间就算没有额外的空行也显示成两行，而不是像Latex那样显示成一行。
    # +autolink_bare_uris: Makes all absolute URIs into links, even when not surrounded by pointy braces <...>
    '--from', 'markdown-smart+backtick_code_blocks-implicit_figures+gfm_auto_identifiers+intraword_underscores+hard_line_breaks+autolink_bare_uris',
  ]
```

也可以试试直接传入`gfm`。但我没试过。

### 方案二：hexo-renderer-markdown

参考：
<https://github.com/wujun234/hexo-theme-tree/issues/14>

<https://github.com/niemingzhao/hexo-renderer-markdown>

```shell
npm un hexo-renderer-marked --save
npm i hexo-renderer-markdown --save
```

但是hexo-renderer-markdown好像有high severity vulnerabilities。而且仍然有些Latex公式不能正常显示。比如`\underset{theta}{\bowtie}`。而且单行公式里如果有`\}`的话公式就不能正常显示了。

### 方案三：hexo-math + hexo-renderer-marked

hexo-math官方教程: <https://github.com/hexojs/hexo-math>

```shell
npm i hexo-renderer-marked --save
npm i hexo-math --save
```

但是由于hexo-renderer-marked的原因，hexo-math的公式编辑只能是这种形式：

- katex公式

```text
{% katex %}
c = \pm\sqrt{a^2 + b^2}
{% endkatex %}
```

$c = \pm\sqrt{a^2 + b^2}$

- mathjax公式

```text
{% mathjax %}
\frac{1}{x^2-1}
{% endmathjax %}
```

$\frac{1}{x^2-1}$

### 失败的方案：hexo-math + hexo-renderer-kramed

教程：<https://zhuanlan.zhihu.com/p/108766968>。

公式会消失。这可能是因为hexo-renderer-kramed只支持到hexo 3，然后我用的是hexo 5。

hexo-renderer-kramed: <https://github.com/sun11/hexo-renderer-kramed>
