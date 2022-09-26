---
title: Linux压缩pdf
date: 2020-08-21 12:51:27
tags:
---

参考：
<https://stackoverflow.com/questions/9625967/changing-pdf-image-dpi-using-gs>
<http://milan.kupcevic.net/ghostscript-ps-pdf/>

```shell
gs -q -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -sOutputFile=output.pdf  input.pdf
```
各种PDFSETTINGS对应的dpi如下
![在这里插入图片描述](Linux压缩pdf/20200821125042899.png)
