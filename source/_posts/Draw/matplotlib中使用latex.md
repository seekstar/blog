---
title: matplotlib中使用latex
date: 2020-12-10 18:13:06
---

比方说要插入一个`千分之`符号。
参考：<https://stackoverflow.com/questions/44242079/how-do-i-get-a-per-mille-sign-in-my-axis-title-using-latex-in-matplotlib>
如果使用xelatex，那就`\usepackage{amsmath}`
如果使用pdflatex，就`\usepackage{textcomb}`
然后text模式下的`\textperthousand`就是`千分之`符号了。
# import
```py
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
```
# 加载latex宏包
参考：
<https://stackoverflow.com/questions/41453109/how-to-write-your-own-latex-preamble-in-matplotlib>
<https://stackoverflow.com/questions/32725483/matplotllib-and-xelatex>
如果使用pdflatex的话，就这样
```py
mpl.rcParams.update({
    'text.usetex': True,
    'pgf.preamble': r'\usepackage{textcomb}'
})
```
如果使用xelatex的话，就这样
```py
## TeX preamble
mpl.rcParams.update({
    'text.usetex': True,
    'pgf.texsystem': 'xelatex',
    #'pgf.preamble': r'\usepackage{amsmath} `...'
    'pgf.preamble': r'\usepackage{amsmath}'
})
```
# 使用
类似这样
```py
plt.ylabel(r"DRAM consumption(\textperthousand)")
```
# LaTeX Error: File `type1ec.sty' not found.
<https://stackoverflow.com/questions/11354149/python-unable-to-render-tex-in-matplotlib>
```shell
sudo apt install cm-super
```

# legend消失
检查一下Latex的报错信息。比如说用了下划线啥的。
如果没有问题的话，留意一下是不是没有把开启usetex的语句放到开头。一个图中可能不能一部分usetex，一部分不用？
