---
title: Linux OCR
date: 2022-09-16 14:55:35
tags:
---

可以用`Tesseract`。项目主页：<https://tesseract-ocr.github.io/>，github: <https://github.com/tesseract-ocr/tesseract>

可以安装对应的图形界面，例如`gImageReader`。Arch Linux可以装：`sudo pacman -S gimagereader-qt`

`Tesseract`支持的语言列表：<https://man.archlinux.org/man/community/tesseract/tesseract.1.en#LANGUAGES_AND_SCRIPTS>

`Tesseract`默认只支持英语，如果要支持其他语言，可以从上面的语言列表中找到对应语言的编码，比如简体中文的编码是`chi_sim` (Chinese simplified)，然后安装对应的语言包。Arch Linux：`sudo pacman -S tesseract-data-chi_sim`
