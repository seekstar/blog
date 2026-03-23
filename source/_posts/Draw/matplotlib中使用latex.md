---
title: matplotlib中使用latex
date: 2020-12-10 18:13:06
---

## 简单的Latex符号

使用简单的Latex符号不需要安装latex，可以直接用。比如叉乘`\times`: $\times$

直接这样即可：

```py
r'Get $\times$ 16KiB'
```

## 使用完整版Latex

比方说要插入一个`千分之`符号。
参考：<https://stackoverflow.com/questions/44242079/how-do-i-get-a-per-mille-sign-in-my-axis-title-using-latex-in-matplotlib>
如果使用xelatex，那就`\usepackage{amsmath}`
如果使用pdflatex，就`\usepackage{textcomb}`
然后text模式下的`\textperthousand`就是`千分之`符号了。

### 安装Latex

```shell
# Debian
# pdflatex
sudo apt install -y texlive-latex-base
# type1cm.sty
sudo apt install -y texlive-latex-extra
# type1ec.sty
sudo apt install -y cm-super-minimal
# dvipng
sudo apt install -y dvipng
```

### import

```py
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
```

### 加载latex宏包

参考：
<https://stackoverflow.com/questions/41453109/how-to-write-your-own-latex-preamble-in-matplotlib>
<https://stackoverflow.com/questions/32725483/matplotllib-and-xelatex>

```py
mpl.rcParams.update({
    'text.usetex': True,
    'pgf.preamble': r'\usepackage{textcomb}',
})
```

默认是pdflatex。如果要使用xelatex的话，加上`'pgf.texsystem': 'xelatex',`即可。

如果要使用`Linux Libertine`:

```py
mpl.rcParams.update({
    'font.family': 'serif',
    'font.serif': ['Linux Libertine O'],
    'text.usetex': True,
    'text.latex.preamble': r'\usepackage{amsmath} \usepackage{libertine}',
})
```

### 使用

类似这样

```py
plt.ylabel(r"DRAM consumption(\textperthousand)")
```

### legend消失

检查一下Latex的报错信息。比如说用了下划线啥的。
如果没有问题的话，留意一下是不是没有把开启usetex的语句放到开头。一个图中可能不能一部分usetex，一部分不用？
