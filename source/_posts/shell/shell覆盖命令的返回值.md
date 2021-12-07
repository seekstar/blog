---
title: shell覆盖命令的返回值
date: 2021-04-14 12:33:53
---

比方说在```set -e```的脚本里面，如果提前知道一个命令会返回非零值，但是又想让脚本继续执行下去，那就需要把命令的返回值覆盖成0。

shell里```true```命令的返回值是0，```false```命令的返回值是1，因此如果要把命令的返回值覆盖成0，那么

```shell
Command || true
```
如果想覆盖成1，那么
```shell
Command && false
```

吐槽一下，shell的true和false跟C语言相反真的好诡异。。。

参考文献：
<https://stackoverflow.com/questions/36130299/how-to-return-exit-code-0-from-a-failed-command>
