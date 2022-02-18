---
title: hitszthesis Linux使用笔记
date: 2021-02-09 16:51:20
---

# 安装texlive
```shell
# texlive-extra-utils: texdef
# latex-cjk-all: Chinese font package
# texlive-fonts-extra: Fonts such as consolas
# evince: PDF reader
sudo apt install -y texstudio texlive-xetex texlive-extra-utils latex-cjk-all texlive-fonts-extra evince
```

# 下载模板
<https://gitee.com/jingxuanyang/hitszthesis>

# 安装额外依赖

```shell
# texlive-science: siunitx.sty
# latexmk: make clean要用
sudo apt -y install texlive-science latexmk
```

参考：
<https://techoverflow.net/2019/07/30/how-to-fix-latex-error-file-siunitx-sty-not-found-on-ubuntu/>

# 配置vscode
我装了这几个插件

![在这里插入图片描述](hitszthesis%20Linux使用笔记/20210209161740856.png)

ctrl+s就可以自动编译，不需要命令行。

# 编译
```shell
make all
```
如果要用vscode的话，要把`main.tex`里的
```
% !TEX program  = XeLaTeX
```
改成
```
% !TEX program  = xelatex
```
否则vscode会报错：`Recipe terminated with fatal error: spawn XeLaTeX ENOENT.`，因为linux是大小写敏感的。

# 添加.gitignore
```
*.sty
*.aux
*.cfg
*.cls
*.glo
*.gls
*.hd
*.idx
*.ilg
*.ind
*.ist
*.log
*.out
*.pdf
hitszthesis.pdf
main.pdf
*.toc
*.bbl
*.blg
*.synctex.gz
*.thm
```
这样commit的时候可以不把这些临时文件commit进去。

![在这里插入图片描述](hitszthesis%20Linux使用笔记/20210209165811672.png)

# 参考文献
在google scholar上搜索文献，然后点击引用

![在这里插入图片描述](hitszthesis%20Linux使用笔记/20210210131710785.png)

选Bibtex

![在这里插入图片描述](hitszthesis%20Linux使用笔记/20210210131747825.png)

![在这里插入图片描述](hitszthesis%20Linux使用笔记/20210210131815121.png)

复制下来放到项目根目录下的`reference.bib`里

![在这里插入图片描述](hitszthesis%20Linux使用笔记/20210210131918685.png)

绿色的那个就是自动生成的名字，要引用时cite这个名字就好了

![在这里插入图片描述](hitszthesis%20Linux使用笔记/20210210132013504.png)

注意更改了`reference.bib`之后要

```
bibtex main
```

才会生效。

然后再编译几下`main.tex`就好了。

![在这里插入图片描述](hitszthesis%20Linux使用笔记/20210210132152797.png)

![在这里插入图片描述](hitszthesis%20Linux使用笔记/20210210132211113.png)

引用misc类型的参考文献可能会报错`Unsupported entry type`。参照<https://blog.csdn.net/haifeng_gu/article/details/107342684>，将`misc`改成`Online`即可。

# 伪代码
hitszthesis的伪代码用的是`algorithm2e`包，已经自带了，不需要另外usepackage。
注意algorithm2e里是用`\;`来结束一条语句，而不是用`\State`来开始一条语句。
algorithm2e教程：
<https://blog.csdn.net/yq_forever/article/details/89815562>
<https://wenda.latexstudio.net/article-5052.html>
<https://tex.stackexchange.com/questions/522327/how-to-change-the-type-of-vertical-line-in-algorithm-environment-while-minimizin>
