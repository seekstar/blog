---
title: vscode使用笔记
date: 2023-03-22 20:28:45
tags:
---

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

来源：<https://stackoverflow.com/questions/44831313/how-to-exclude-file-extensions-and-languages-from-format-on-save-in-vscode>
