---
title: sh -c中使用变量
date: 2019-10-07 13:48:05
---

参考链接：https://unix.stackexchange.com/questions/23179/how-to-send-variable-to-an-inline-shell-script

to=$(pwd)/table.txt
sh -c 'echo 2333 $to'
输出2333，没有to指向的路径。

解决方案：把to变成环境变量。
```bash
to=$(pwd)/table.txt
sh -c 'echo 2333 $to'

export to
sh -c 'echo 2333 $to'
```

输出：
2333
2333 /home/searchstar/test/test/table.txt
