---
title: odbc SQLFetch读到NULL
date: 2020-04-03 23:06:42
---

参考：<https://docs.microsoft.com/en-us/sql/odbc/reference/syntax/sqlbindcol-function?view=sql-server-ver15>

odbc中SQLFetch读到NULL则不会改变那一列对应的缓冲区，而是将对应列的          ```长度/标志```也就是```StrLen_or_Ind```变量设置为```SQL_NULL_DATA```。

例如：
```cpp
SQLLEN enameLen;
SQLVARCHAR ename[45];
//绑定数据
SQLBindCol(serverhstmt,1, SQL_C_CHAR, (void*)ename,sizeof(ename), &enameLen);
SQLFetch(serverhstmt);
```
其中```SQLBindCol```的最后一个参数就是```StrLen_or_Ind```，也就是```长度/标志```。
如果读到的是正常值，则enameLen会被赋值为读到的字符的个数。
如果读到NULL，那么ename里的内容不会被改变，但是enameLen会被设置为```SQL_NULL_DATA```。所以可以这样检测读到的是否是NULL：
```cpp
if (SQL_NULL_DATA == enameLen)
```
