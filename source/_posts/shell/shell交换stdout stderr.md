---
title: shell交换stdout stderr
date: 2021-08-04 01:43:14
---

比如这个脚本myscript.sh：
```shell
#!/bin/sh

echo "I'm stdout";
echo "I'm stderr" >&2;
```

交换它的stdout和stderr可以这样做：
```shell
(sh myscript.sh 3>&2 2>&1 1>&3-) 2>/dev/null
(sh myscript.sh 3>&2 2>&1 1>&3-) >/dev/null 
```

```
I'm stderr
I'm stdout
```

```3>&2```表示将文件描述符2复制为文件描述符3（不是dup，tee才用的dup）。
```2>&1```表示把文件描述符1（stdout）复制为文件描述符2（stderr）。现在进程写入2（stderr）时，我们就能在1（stdout）收到了。
```1>&3-```表示把文件描述符3[移动](http://www.gnu.org/software/bash/manual/bash.html#Moving-File-Descriptors)到文件描述符1，移动完了之后3就被关掉了。所以现在的1存的是原来的2，现在的2存的是原来1。

命令里的小括号的作用是新开一个shell，防止重定向乱掉。如果不用小括号，比如```3>&2 2>&1 1>&3- > /dev/null```，```> /dev/null```就会把现在的1给重定向掉，而现在的1其实是原先的stderr了。

原文：<https://stackoverflow.com/questions/13299317/io-redirection-swapping-stdout-and-stderr>

参考文献
[shell中各种括号的作用()、(())、[]、[[]]、{}](https://blog.csdn.net/taiyang1987912/article/details/39551385)
