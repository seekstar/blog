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
