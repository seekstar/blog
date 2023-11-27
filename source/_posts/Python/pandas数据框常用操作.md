---
title: pandas数据框常用操作
date: 2021-08-21 00:36:44
---

pandas官方文档：<https://pandas.pydata.org/docs/reference/>

DataFrame官方文档：<https://pandas.pydata.org/docs/reference/frame.html>

- {% post_link Python/'pandas判断数据框是否相等' %}
- {% post_link Python/'pandas数据框获取行数列数' %}
- {% post_link Python/'python dataframe根据列号取出列' %}

添加新列：<https://www.geeksforgeeks.org/adding-new-column-to-existing-dataframe-in-pandas/>

## 创建

构造函数：<https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.html>

### 从Series list创建

```py
li = []
li.append(pd.Series([1, 2, 3]))
li.append(pd.Series([4, 5, 6]))
# https://stackoverflow.com/a/57034111/13688160
# Series相当于列向量，所以concat的方向为column
# 然后.T转置一下
df = pd.concat(li, axis=1).T
# https://www.kdnuggets.com/2022/11/4-ways-rename-pandas-columns.html
df.columns = ['a', 'b', 'c']
df
```

```text
   a  b  c
0  1  2  3
1  4  5  6
```

## 从stdin读取

直接把`sys.stdin`当file输入进去即可：

```py
latencies = pd.read_table(sys.stdin, names=['operation', 'latency(ns)'], delim_whitespace=True)
```

来源：<https://stackoverflow.com/questions/18495846/pandas-data-from-stdin>

## 添加新行

<https://pandas.pydata.org/docs/reference/api/pandas.concat.html#pandas.concat>

注意，append已经被deprecated了：<https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.append.html>

如果需要把Series作为行添加到DataFrame里，需要先将其转换成DataFrame，再转置：

```py
r = pd.Series([1, 2, 3], index = ['col1', 'col2', 'col3'])
d = pd.DataFrame({'col1': [0, 1], 'col2': [2, 3], 'col3': [4, 5]})
pd.concat([d, pd.DataFrame(r).T])
```

注意，`pd.concat`会返回一个新的DataFrame，所以复杂度是`O(n)`的：<https://stackoverflow.com/a/36489724/13688160>

## 根据index取出行

用`.iloc`，与python自带的list的语法类似：

```py
test = pd.DataFrame({'col1': range(0, 10), 'col2': range(10, 20)})
# 取出第2行到第4行：
test.iloc[1:4]
# 取出最后一行
test.iloc[-1]
```

## 取出满足条件的行

```python
# 选择年龄大于25岁且性别为男性的数据行
print(df[(df['age'] > 25) & (df['gender'] == 'male')])
```

来源：<https://www.ycpai.cn/python/UcXZsYr8.html>

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

### 每3行分组并求均值

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

### 将某列的值相同的合并成一个list

<https://stackoverflow.com/questions/22219004/how-to-group-dataframe-rows-into-list-in-pandas-groupby>

## 遍历

<https://stackoverflow.com/questions/16476924/how-to-iterate-over-rows-in-a-dataframe-in-pandas>
