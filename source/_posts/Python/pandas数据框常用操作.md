---
title: pandas数据框常用操作
date: 2021-08-21 00:36:44
---

pandas官方文档：<https://pandas.pydata.org/docs/reference/>

DataFrame官方文档：<https://pandas.pydata.org/docs/reference/frame.html>

新建：<https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.html>

{% post_link Python/'pandas判断数据框是否相等' %}
{% post_link Python/'pandas数据框获取行数列数' %}
{% post_link Python/'python dataframe根据列号取出列' %}

添加新列：<https://www.geeksforgeeks.org/adding-new-column-to-existing-dataframe-in-pandas/>

## 添加新行

<https://pandas.pydata.org/docs/reference/api/pandas.concat.html#pandas.concat>

注意，append已经被deprecated了：<https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.append.html>

如果需要把Series作为行添加到DataFrame里，需要先将其转换成DataFrame，再转置：

```py
r = pd.Series([1, 2, 3], index = ['col1', 'col2', 'col3'])
d = pd.DataFrame({'col1': [0, 1], 'col2': [2, 3], 'col3': [4, 5]})
pd.concat([d, pd.DataFrame(r).T])
```

## 取出指定范围的行

与python自带的list的语法类似：

```py
test = pd.DataFrame({'col1': range(0, 10), 'col2': range(10, 20)})
# 取出第2行到第4行：
test[1:4]
```

## 取出多列

```py
test = pd.DataFrame({'col1': [0, 1], 'col2': [2, 3], 'col3': [4, 5]})
# 取出col2和col1列
test[['col2', 'col1']]
```

输出：

```text
   col2  col1
0     2     0
1     3     1
```

## 求均值

<https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.mean.html>

```py
test = pd.DataFrame({'col1': [0, 1, 2, 3], 'col2': [4, 5, 6, 7]})
# 求每列的平均数
test.mean()
test.mean(axis=0)
# 求每行的平均数
test.mean(axis=1)
```

## groupby

<https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.groupby.html>

每3行分组并求均值：

```py
test = pd.DataFrame({'col1': range(0, 10), 'col2': range(10, 20)})
test.groupby(test.index // 3).mean()
```

输出：

```text
   col1  col2
0   1.0  11.0
1   4.0  14.0
2   7.0  17.0
3   9.0  19.0
```
