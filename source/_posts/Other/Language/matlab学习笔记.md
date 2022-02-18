---
title: matlab学习笔记
date: 2020-04-11 11:50:59
tags:
---

# 注释
参考：<https://blog.csdn.net/yyywww666/article/details/48752643>

单行注释用`%`
多行注释用`%{ ..... %}`
# 定义符号变量
```matlab
syms f x
```
中间不能加逗号

# 定义整数
```matlab
n = int32(0);
```

# 把符号函数转成普通函数
```matlab
f = x ^ 2
fx = matlabFunction(f)
```

# 生成序列
```
a:step:b
```
生成从a到b(含)的步长为step的序列。
例：
```matlab
1:0.1:1.5
```
```
ans =

    1.0000    1.1000    1.2000    1.3000    1.4000    1.5000
```
```matlab
1:0.2:1.5
```
```
ans =

    1.0000    1.2000    1.4000
```

# 画图
## f(x)
```matlab
X = -10:0.01:100;
Y = fx(X);
plot(X, Y);
```
如果不想让这个图覆盖原来的，可以在plot前加上
```matlab
figure;
```
参考：<https://zhidao.baidu.com/question/355393201>
