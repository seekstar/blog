---
title: bash计算浮点数
date: 2021-01-07 23:55:01
---

```shell
echo "2 / 3" | bc -l
```
```
.66666666666666666666
```
如果想要前导零
```shell
echo "2 / 3" | bc -l | xargs printf "%f"
```
这里还有一堆解决方案：<https://stackoverflow.com/questions/8402181/how-do-i-get-bc1-to-print-the-leading-zero>

参考文献
<https://blog.csdn.net/hanhaixingchen/article/details/71707566>

bash做运算是真的烦。有点想转python了
