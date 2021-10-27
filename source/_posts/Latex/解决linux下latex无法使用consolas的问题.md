---
title: 解决linux下latex无法使用consolas的问题
date: 2019-09-25 02:31:30
---

在网上找了好久都没有合适的解决方案TT。
结合报错信息，发现其实/usr/local/texlive/2019中已经有inconsolata，但是编译时xelatex找的是/usr/share/texlive，里面有一些字体没有（我也不懂为什么官方要这样搞）。于是我们只需要把/usr/share下的相关文件夹替换成/usr/local/texlive/2019中的相关文件夹即可。
代码如下：
```bash
sudo trash-put /usr/share/texlive/texmf-dist/tex/latex
ln -s /usr/local/texlive/2019/texmf-dist/tex/latex/ /usr/share/texlive/texmf-dist/tex/latex
sudo trash-put /usr/share/texlive/texmf-dist/fonts
ln -s /usr/local/texlive/2019/texmf-dist/fonts/ /usr/share/texlive/texmf-dist/fonts
sudo mktexlsr	#refresh sty
#or sudo texhash
```
其中trash-put 是trash-cli中的一个命令。通过
sudo apt-get install trash-cli
安装

示例代码：
```tex
% !TEX program = xelatex

\documentclass[UTF8]{ctexart}
\title{test}
\author{searchstar}

\usepackage{CJK}
\usepackage{fontspec}
\usepackage{inconsolata}

\fontspec{inconsolata}
\setmonofont[StylisticSet=1]{inconsolata}	%这里StylisticSet=1时"l"是卷的。（有时候等于3的时候是卷的。玄学）

\begin{document}
	\maketitle

	\ttfamily{00000 Hello consolas!}

\end{document}
```
效果：
![](https://img-blog.csdnimg.cn/20190925022903920.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxOTYxNDU5,size_16,color_FFFFFF,t_70)这样就可以愉快地使用consolas了。
