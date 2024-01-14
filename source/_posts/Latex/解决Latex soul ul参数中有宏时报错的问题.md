---
title: 解决Latex soul ul参数中有宏时报错的问题
date: 2023-09-14 21:39:26
tags:
---

没有宏时直接用就好了：[用soul宏包解决Latex \underline换行问题](https://blog.csdn.net/weixin_44465434/article/details/126912203)

但是如果里面有宏则会报错：

```tex
\def\testc#{test}
\ul{\testc{}}
```

```text
Use of \testc doesn't match its definition.
```

有两种解决方案：

## `soulregister`

这种方案是非侵入式的。

```tex
\soulregister\testc7
```

来源：<https://tex.stackexchange.com/questions/139463/how-to-make-hl-highlighting-to-automatically-place-incompatible-commands-in/139500#139500>

可以做一个宏来自动化register:

```tex
\newcommand{\defmacro}[2]{%
  \expandafter\def\csname#1\endcsname##{#2}
  \expandafter\soulregister\csname#1\endcsname7
}
\defmacro{test}{\emph{Test}}
```

`\expandafter\def`表示先展开`\def`后面的宏。第一个参数`#1`是`test`，所以`\csname#1\endcsname`展开之后会变成`\test`。`##`展开之后会变成`#`。第二个参数`#2`是`\emph{Test}`。所以第一句展开之后就变成了`\def\test#{\emph{Test}}`。

同样，`\expandafter\soulregister`表示先展开`\soulregister`之后的宏，所以第二句展开之后就变成了`\soulregister\test7`。

## 提前expand

这种方案需要定义一个新的宏。

```tex
\makeatletter
\def\myul#1{%
  \protected@edef\tempa{#1}%
  \ul\tempa%
}
\makeatother
```

然后用这个新的宏就好了：

```tex
\myul{233 \testc{} 2333}
```

注意这里面`\protected@edef`不能换成`\edef`，不然碰上`\emph`就会炸。

来源：<https://tex.stackexchange.com/a/126244/256676>

参考：

<https://tex.stackexchange.com/questions/244694/writing-to-aux-you-cant-use-a-prefix-with-the-character>

<https://en.wikibooks.org/wiki/TeX/edef>

## 失败的方案

```tex
\def\myul#1{
\def\arga{#1}
\ul\arga
}
```

这种方法遇到嵌套宏就不行了。

来源：<https://tex.stackexchange.com/questions/496833/package-soul-underline-problem-with-macro-text>
