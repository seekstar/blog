---
title: "Clang 'constexpr' specifier is incompatible with C++98 [Semantic Issue]"
date: 2020-05-01 21:22:54
tags:
---

参考：
<https://github.com/jbenden/vscode-c-cpp-flylint/issues/46>
<https://clang.llvm.org/docs/DiagnosticsReference.html#wc-98-compat>

加上参数"-Wno-c++98-compat"即可消去这条warning。

在vscode的flylint插件中，在settings.json里加上
```
"c-cpp-flylint.clang.extraArgs": ["-Wno-c++98-compat"]
```
即可。
