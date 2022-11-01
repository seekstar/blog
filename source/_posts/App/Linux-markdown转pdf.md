---
title: Linux markdown转pdf
date: 2022-06-14 21:14:49
tags:
---

## vscode插件：Markdown Preview Enhanced

在预览窗口右键，选择`Open in Browser`，然后HTML就会在浏览器中打开，接着在浏览器中将其打印为PDF即可。

## pandoc

看这里：[Pandoc+TeXLive实现Markdown转PDF](https://www.jianshu.com/p/1d02fc5121c2)

```shell
pandoc --toc -N -s --pdf-engine=xelatex -V CJKmainfont='Source Han Serif CN' --highlight-style tango -V colorlinks=true -o manual.pdf manual.md
```

`--toc`: 生成目录

`-N`: 编号

`-s`: standalone

`xelatex`: 支持中文。默认的pdflatex不支持中文

`-V CJKmainfont=xxx`: 设置字体。可用字体可以用`fc-list :lang=zh`查询。这里用的是思源宋体`Source Han Serif CN`。

`--highlight-style`: 高亮风格。可用风格可通过`pandoc --list-highlight-styles`查看。下面是我尝试过的风格：

- pygments：默认。代码跟正文没有明显边界，而且没有背景色，容易跟正文弄混。

- tango: 代码块背景色为淡灰色。

`-V colorlinks=true`: 给链接染色。来源：<https://stackoverflow.com/questions/58866818/pandoc-conversion-to-pdf-not-providing-colored-hyptertext-links>

### 代码块不会自动换行

不知道怎么解决。相关：

[使用 Pandoc 来转换 Markdown 为漂亮的 PDF 格式](https://blog.csdn.net/u013019701/article/details/119512493)

<https://gist.github.com/c-x/2e5c6e39b334676378c1>

<https://stackoverflow.com/a/48507868/13688160>

### block quote无背景色

block quote默认使用了Latex的`quote`环境，效果只是往右缩进了一些，很难与上下文区分开。可以设置背景色之类的，但是很麻烦：

<https://jdhao.github.io/2019/05/30/markdown2pdf_pandoc/#change-the-default-style-of-block-quote>

<https://stackoverflow.com/questions/70141530/set-a-background-color-for-a-markdown-multiline-block-or-citation-attempting-to>

<https://tex.stackexchange.com/questions/154528/how-to-change-the-background-color-and-border-of-a-pandoc-generated-blockquote>

## markdown-pdf

```shell
npm install -g markdown-pdf
markdown-pdf <markdown-file-path>
```

似乎不支持Latex公式？

原文：<https://stackoverflow.com/a/37977314/13688160>

## vscode插件：Markdown PDF

安装yzane的Markdown PDF插件。然后点进要转换的markdown文件，右键，选择`Markdown PDF: Export (pdf)`。缺点是会使得右键菜单条目太多。而且似乎不支持Latex公式？

<https://github.com/yzane/vscode-markdown-pdf>

[how to export pdf with latex](https://github.com/yzane/vscode-markdown-pdf/issues/21)

[Math support](https://github.com/yzane/vscode-markdown-pdf/issues/276)

但是这里又好像说可以？：[A bug of rendering latex formula #221](https://github.com/yzane/vscode-markdown-pdf/issues/221)

原文：<https://stackoverflow.com/a/55484165/13688160>
