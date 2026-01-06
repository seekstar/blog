---
title: algorithm2e包参数
date: 2021-06-04 15:58:28
---

完整参数见官方文档：<http://tug.ctan.org/macros/latex/contrib/algorithm2e/doc/algorithm2e.pdf>

这里介绍几个常用的。

测试代码：

```tex
\documentclass[UTF8]{ctexart}

\usepackage[linesnumbered, ruled, vlined]{algorithm2e}

\begin{document}

\begin{algorithm}
	\caption{2333}\label{alg:xxx}
	\DontPrintSemicolon
	\If{2333}{
		123333 \;
	}
	\For{2333}{
		123333333 \;
		2333 \;
	}
\end{algorithm}

\end{document}
```

## 啥参数都没有

![在这里插入图片描述](algorithm2e包参数/2021060415492676.png)

## linesnumbered

标上行号。

![在这里插入图片描述](algorithm2e包参数/20210604155025191.png)

## ruled

![在这里插入图片描述](algorithm2e包参数/20210604155102628.png)

## noend

![在这里插入图片描述](algorithm2e包参数/20210604155153346.png)

## vlined

默认使用`\SetAlgoVlined`。

![在这里插入图片描述](algorithm2e包参数/20210604155640722.png)
