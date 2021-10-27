---
title: vscode javascript用firefox来debug
date: 2019-10-28 16:15:12
---

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "firefox",
            "request": "launch",
            "name": "Launch firefox against localhost",
            "firefoxExecutable": "D:/Program Files/Mozilla Firefox/firefox.exe",
            "url": "file:///要跑的文件在本地的路径",
            "webRoot": "${workspaceRoot}"
        },
    ],
    "code-runner.executorMap": {
        "javascript": "node",
        "html": "firefox",
    }
}
```

url的例子：

```json
"url": "file:///D:/git/project/example.html",
```
