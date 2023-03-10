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

但是默认的markdown语法跟github的markdown语法不一样。

这篇文章提供了一个workaround：<https://blog.rule55.com/hexo/>，即在`_config.yml`里加入

```yml
# Configure pandoc to use all github markdown format extensions
# extensions as of 2018 is an undocumented feature of hexo-renderer-pandoc
# Adding all extensions for github so we don't have to change index.js of
# hexo-renderer-pandoc.
pandoc:
  extensions:
    - -implicit_figures # 防止在图片后面将方括号里的东西作为caption。
    - +gfm_auto_identifiers+angle_brackets_escapable # Not available in pandoc 1.16
    - +pipe_tables+raw_html+fenced_code_blocks
    - -ascii_identifiers+backtick_code_blocks+autolink_bare_uris
    - +intraword_underscores+strikeout+hard_line_breaks+emoji
    - +shortcut_reference_links
```

其中`-implicit_figures`的来源：<https://github.com/wzpan/hexo-renderer-pandoc/issues/34>

但是感觉这样还是不太优雅。要是可以直接像其他渲染器那样直接传进一个`gfm`就好了。好像pandoc是有这个参数的，但是我在插件里的`index.js`里把`markdown-smart`改成`gfm`，并且改了后面的`register`之后没反应，不知道为什么。

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
