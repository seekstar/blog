---
title: python dataframe根据列号取出列
date: 2020-12-10 14:44:47
---

原文：<https://thispointer.com/select-rows-columns-by-name-or-index-in-dataframe-using-loc-iloc-python-pandas/>

比如这个数据：
```py
students = pd.DataFrame([ ('jack', 34, 'Sydeny') ,
             ('Riti', 30, 'Delhi' ) ,
             ('Aadi', 16, 'New York') ], columns = ['Name' , 'Age', 'City'], index=['a', 'b', 'c'])
```
```
   Name  Age      City
a  jack   34    Sydeny
b  Riti   30     Delhi
c  Aadi   16  New York
```
注意列号是从0开始的。取出列号为1的列：
```py
students.iloc[:,1]
```
```
a    34
b    30
c    16
Name: Age, dtype: int64
```
取出列号为0和2的列：
```py
students.iloc[:,[0,2]]
```
```
   Name      City
a  jack    Sydeny
b  Riti     Delhi
c  Aadi  New York
```
