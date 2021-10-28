---
title: odbc for C++学习笔记
date: 2020-03-29 23:54:04
---

# 连接服务器
参考：<https://blog.csdn.net/jadeshu/article/details/79474938>
```cpp
SQLRETURN  SQL_API SQLConnect(SQLHDBC ConnectionHandle,
	SQLCHAR *ServerName, SQLSMALLINT NameLength1,
	SQLCHAR *UserName, SQLSMALLINT NameLength2,
	SQLCHAR *Authentication, SQLSMALLINT NameLength3);
```
其中ServerName一般为数据源名称，NameLength1、2、3一般写SQL_NTS即可(Null Terminated String)。如果数据源配置了用户名和密码则UserName和Authentication直接填NULL，NameLength2和NameLength3直接写0即可（仍然填SQL_NTS也可以）。

# 读取数据
## SQLBindCol
```cpp
SQLRETURN  SQL_API SQLBindCol(SQLHSTMT StatementHandle,
	SQLUSMALLINT ColumnNumber, SQLSMALLINT TargetType,
	SQLPOINTER TargetValue, SQLLEN BufferLength,
	SQLLEN *StrLen_or_Ind);
```
## ColumnNumber
从1开始。
## TargetType
完整的取值范围可以到<sqlext.h>中找。常用的有
| sql类型 | TargetType | odbc typedef | C类型 |
| ---- | ---- | ---- | ---- |
| CHAR | SQL_C_CHAR | SQLCHAR | char |
| INT | SQL_C_SLONG | SQLINTEGER | int |
| BIGINT UNSIGNED | SQL_C_UBIGINT | SQLUBIGINT | uint64_t |
| BINARY | SQL_C_BINARY | 无 | 随便 |
| BLOB | SQL_C_BINARY | 无 | 随便 |
## BufferLength
用来存数据的缓冲区的长度。odbc将只使用缓冲区的前BufferLength个字节的空间。如果要存入的数据达到或超过了BufferLength，则只把BufferLength字节的数据存入缓冲区。

## 读取字符串示例
由于C语言中字符串以```'\0'```结尾，所以缓冲区的长度要比数据库中的多1。例如某表第6列为
```sql
dno char(10)
```
则读取它的代码如下：
```cpp
SQLCHAR dno[11];
SQLLEN dnoLen;
SQLBindCol(serverhstmt, 6, SQL_C_CHAR, (void*)dno, sizeof(dno) - 1, &dnoLen);
while (SQL_NO_DATA != SQLFetch(serverhstmt) {
	if (dnoLen != SQL_NULL_DATA) {
		dno[dnoLen] = 0;
		do_some_thing_with_dno
	} else {
		handle_null_data
	}
}
```
# SQLBindParameter
microsoft官方文档：<https://docs.microsoft.com/en-us/sql/odbc/reference/syntax/sqlbindparameter-function?view=sql-server-ver15>
```cpp
SQLRETURN SQLBindParameter(  
      SQLHSTMT        StatementHandle,  
      SQLUSMALLINT    ParameterNumber,  
      SQLSMALLINT     InputOutputType,  
      SQLSMALLINT     ValueType,  
      SQLSMALLINT     ParameterType,  
      SQLULEN         ColumnSize,  
      SQLSMALLINT     DecimalDigits,  
      SQLPOINTER      ParameterValuePtr,  
      SQLLEN          BufferLength,  
      SQLLEN *        StrLen_or_IndPtr);  
 ```
## ParameterNumber
从１开始
## InputOutputType
一般是```SQL_PARAM_INPUT```和```SQL_PARAM_OUTPUT```
## ValueType
同```SQLBindCol```
## ParameterType
告诉odbc这一列的数据类型。
与ValueType的关系：
![在这里插入图片描述](odbc%20for%20C++学习笔记/2020050214311733.png)
图片来源：<<https://docs.microsoft.com/en-us/sql/odbc/reference/appendixes/converting-data-from-c-to-sql-data-types?view=sql-server-ver15>>

## StrLen_or_IndPtr
如果为NULL则相当于写入的数据是null-terminated。

# 获取错误信息
参考：
<https://blog.csdn.net/cztjing/article/details/6631031>
<https://www.cnblogs.com/liangxiaofeng/p/5866354.html>
用SQLGetDiagRec
```cpp
SQLINTEGER errnative;

UCHAR errmsg[255];
SQLSMALLINT errmsglen;

UCHAR errstate[5];
SQLGetDiagRec(SQL_HANDLE_STMT, serverhstmt,
       1, errstate,
       &errnative, errmsg, sizeof(errmsg), &errmsglen);
ostringstream err;
err << "errstate: " << errstate << "\nerrnative: " << errnative << "\nerrmsg: " << errmsg;
```
