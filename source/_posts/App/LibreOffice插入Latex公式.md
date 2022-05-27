---
title: LibreOffice插入Latex公式
date: 2022-05-27 13:47:25
tags:
---

安装`TexMaths`插件，对于ArchLinux：

```shell
sudo pacman -S libreoffice-extension-texmaths
```

然后工具栏会出现一个$\pi$的图标。先确保当前没有选中任何对象，然后点击$\pi$图标就可以编辑公式了，然后点击`Latex`按钮或者`ctrl+enter`，编辑的公式就出现在了中间。接下来需要手动把公式移到合适的位置。如果要编辑已经存在的公式，需要单击选中这个公式，然后点击$\pi$图标。但是有时候好像会出问题？可以试试先选中别的对象，然后再重新单击选中公式。

行内公式目前还不支持：<https://superuser.com/questions/680374/how-to-embed-formulas-in-a-line-of-text-using-openoffice-impress>

参考：<https://tex.stackexchange.com/questions/150503/how-to-insert-latex-formulas-in-libreoffice>
