---
title: Linux markdown转pdf
date: 2022-06-14 21:14:49
tags:
---

## 用vscode插件

安装yzane的Markdown PDF插件。然后点进要转换的markdown文件，右键，选择`Markdown PDF: Export (pdf)`。缺点是会使得右键菜单条目太多。

原文：<https://stackoverflow.com/a/55484165/13688160>

## markdown-pdf

```shell
npm install -g markdown-pdf
markdown-pdf <markdown-file-path>
```

原文：<https://stackoverflow.com/a/37977314/13688160>

## pandoc

看这里：[Pandoc+TeXLive实现Markdown转PDF](https://www.jianshu.com/p/1d02fc5121c2)

```shell
pandoc --toc -N -s --pdf-engine=xelatex -V CJKmainfont='Source Han Serif CN' --highlight-style tango -o manual.pdf manual.md
```

`--toc`: 生成目录

`-N`: 编号

`-s`: standalone

`xelatex`: 支持中文。默认的pdflatex不支持中文

`-V CJKmainfont=xxx`: 设置字体。可用字体可以用`fc-list :lang=zh`查询。这里用的是思源宋体`Source Han Serif CN`。

`--highlight-style`: 高亮风格。可用风格可通过`pandoc --list-highlight-styles`查看。下面是我尝试过的风格：

- pygments：默认。代码跟正文没有明显边界，而且没有背景色，容易跟正文弄混。

- tango: 代码块背景色为淡灰色。

但是代码块不会自动换行，不知道怎么解决。相关：

[使用 Pandoc 来转换 Markdown 为漂亮的 PDF 格式](https://blog.csdn.net/u013019701/article/details/119512493)

<https://gist.github.com/c-x/2e5c6e39b334676378c1>

<https://stackoverflow.com/a/48507868/13688160>
