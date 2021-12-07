---
title: "vscode: You must invoke LaTeX with the -shell-escape flag."
date: 2021-04-13 23:59:34
---

在```.vscode/settings.json```里写入：
```json
{
    "latex-workshop.latex.magic.args": [
        "-synctex=1",
        "-interaction=nonstopmode",
        "-file-line-error",
        "-shell-escape",
        "%DOC%"
    ],
    "latex-workshop.latex.tools": [
        {
            "name": "xelatex",
            "command": "xelatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "-shell-escape",
                "%DOC%"
            ]
        },
        {
            "name": "pdflatex",
            "command": "pdflatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "-shell-escape",
                "%DOC%"
            ]
        },
    ]
}
```

参考文献：
<https://blog.csdn.net/qq_45890199/article/details/105330856>
