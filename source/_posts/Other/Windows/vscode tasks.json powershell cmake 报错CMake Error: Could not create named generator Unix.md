---
title: "vscode tasks.json powershell cmake 报错CMake Error: Could not create named generator Unix"
date: 2020-09-14 20:09:08
tags:
---

搞了半天，原来是因为tasks.json里要转义，powershell的单引号里面的东西还是要转义，然后vscode把它在powershell里执行的时候又要转义，所以要转义三层。

```json
            "windows": {
                "command": "powershell",
                "args": [
                    "mkdir -Force build; cd build; cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -G \\\\\\\"Unix Makefiles\\\\\\\"; make"
                ]
            },
```
或者可以把powershell那层去掉，这样只需要转义两层了。
```json
            "windows": {
                "command": "mkdir -Force build; cd build; cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -G \\\"Unix Makefiles\\\"; make",
            },
```
