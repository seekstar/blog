---
title: vscode断点停在错误的文件
date: 2023-04-25 21:55:57
tags:
---

在`launch.json`中加入：

```json
            "sourceFileMap":{
                "/项目/绝对/路径": {
                    "editorPath": "/项目/绝对/路径",
                    "useForBreakpoints": true
                }
            },
```

来源：<https://github.com/microsoft/vscode-cpptools/issues/6754#issuecomment-756964069>
