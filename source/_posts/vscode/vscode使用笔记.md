---
title: vscode使用笔记
date: 2023-03-22 20:28:45
tags:
---

## Debug: attach到某个进程

安装插件：`WebFreak`的`Native Debug`

在`.vscode/launch.json`里：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Attach to PID",
            "type": "gdb",
            "request": "attach",
            "target": "要attach到的PID",
            "cwd": "${workspaceRoot}",
            "valuesFormatting": "parseText"
        }
    ]
}
```

## 只对特定语言开启保存时自动格式化

例如只对js开启保存时自动格式化：

```json
"[javascript]": {
    "editor.formatOnSave": true
}
```

Language Identifiers: <https://code.visualstudio.com/docs/languages/identifiers>

补充：

| Language Identifier | 含义 |
| ---- | ---- |
| cmake | `CMakeLists.txt` |
| jsonc | JSON with Comments |
| markdown | Markdown |

来源：<https://stackoverflow.com/questions/44831313/how-to-exclude-file-extensions-and-languages-from-format-on-save-in-vscode>

## 切换字体

默认的字体不行，`1`和`l`都分不清。可以在`Editor: Font Family`里更改字体，推荐`Hack`：

```text
'Hack', 'monospace', monospace
```
