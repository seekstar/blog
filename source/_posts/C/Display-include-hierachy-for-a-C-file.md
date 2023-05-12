---
title: Display include hierachy for a C/C++ file
date: 2023-05-12 12:50:37
tags:
---

>In fact, your GCC compiler can output a dependency list, too - but it is not a .dot file that can be feed to GraphViz. The options are -H, -M (a tree), and -MM (same as -M, but only user headers are counted).

<https://github.com/Leedehai/C-include-2-dot>

Example:

```shell
gcc main.cpp -H -I/path/to/include/directory
```
