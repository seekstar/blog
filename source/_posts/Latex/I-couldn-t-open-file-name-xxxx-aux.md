---
title: I couldn\'t open file name xxxx.aux
date: 2023-03-19 19:30:47
tags:
---

手动用`pdflatex`+`bibtex`编译没有问题。但是如果用vscode的latex配套插件编译的话，如果存在bib文件但是文章里没有cite，就可能会出现这个问题，原因未知。

解决方法是加上一个`\cite`，再编译就可以了。

玄学
