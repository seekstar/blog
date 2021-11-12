---
title: odbc读写二进制数据
date: 2020-04-30 01:34:26
tags:
---

这里使用mariadb，其他数据库的操作应该是类似的。

[MySQL字符串和二进制](https://blog.csdn.net/nangeali/article/details/72793323)
[数据类型mariadb官方文档](https://mariadb.com/kb/en/data-types/)
[odbc api官方文档](https://docs.microsoft.com/en-us/sql/odbc/reference/syntax/odbc-api-reference?view=sql-server-ver15)

@[TOC]
# 定长二进制
使用[BINARY](https://mariadb.com/kb/en/binary/)保存定长二进制。
这里以保存哈希后的密码为例。
## 定义表
```sql
CREATE TABLE pw (
	id BIGINT UNSIGNED PRIMARY KEY,
    pw BINARY(4)
)
```

## 写入
官方文档中使用了[SQLPutData](https://docs.microsoft.com/en-us/sql/odbc/reference/syntax/sqlputdata-function?view=sql-server-ver15)
但是比较麻烦。这里直接使用SQLBindParameter把数据绑定到参数上，然后用SQLExecDirect执行insert即可。
关键代码：
```cpp
SQLLEN length = sizeof(binary);
retcode = SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY, SQL_BINARY,
        sizeof(binary), 0, binary, sizeof(binary), &length);
const char *stmt = "INSERT INTO pw VALUES(3, ?);";
	retcode = SQLExecDirect(hstmt, (SQLCHAR*)stmt, SQL_NTS);
```
注意SQLBindParameter的最后一个参数如果为NULL，则相当于告诉odbc遇到NULL时停止，也就是null-terminated。如果要写入含NULL的数据，则必须指定要写入的数据长度。

## 读取
直接用SQLExecDirect执行select，然后用SQLBindCol绑定参数，然后用SQLFetch把数据读出来即可。
关键代码：
```cpp
retcode = SQLExecDirect(hstmt, (SQLCHAR*)"SELECT * FROM pw;", SQL_NTS);
SQLBindCol(hstmt, 1, SQL_C_UBIGINT, &id, sizeof(id), &length);
SQLBindCol(hstmt, 2, SQL_C_BINARY, binary, sizeof(binary), &length);
while (SQL_NO_DATA != SQLFetch(hstmt)) {
    cout << id << '\t' << hex << *(uint32_t*)binary << endl;
}
```
## 完整代码
```cpp
#include <iostream>
#include <cstring>

#if defined(_WIN16) || defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#endif
#include <sqlext.h>

using namespace std;

SQLHENV henv = SQL_NULL_HENV;  
SQLHDBC hdbc = SQL_NULL_HDBC;       
SQLHSTMT hstmt = SQL_NULL_HSTMT;  

void Cleanup() {  
    //释放语句句柄
    if (hstmt != SQL_NULL_HSTMT)  
        SQLFreeHandle(SQL_HANDLE_STMT, hstmt);  
  
    if (hdbc != SQL_NULL_HDBC) {  
        //断开数据库连接
        SQLDisconnect(hdbc);  
        //释放连接句柄
        SQLFreeHandle(SQL_HANDLE_DBC, hdbc);  
    }  
  
    //释放环境句柄句柄
    if (henv != SQL_NULL_HENV)  
        SQLFreeHandle(SQL_HANDLE_ENV, henv);  
}  

int main() {
    SQLRETURN retcode;
    SQLLEN length;

    // Allocate the ODBC environment and save handle.  
    retcode = SQLAllocHandle (SQL_HANDLE_ENV, NULL, &henv);  
    if ((retcode != SQL_SUCCESS_WITH_INFO) && (retcode != SQL_SUCCESS)) {  
        printf("SQLAllocHandle(Env) Failed\n\n");  
        Cleanup();  
        return(9);  
    }  

    // Notify ODBC that this is an ODBC 3.0 app.  
    retcode = SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, (SQLPOINTER) SQL_OV_ODBC3, SQL_IS_INTEGER);  
    if ((retcode != SQL_SUCCESS_WITH_INFO) && (retcode != SQL_SUCCESS)) {  
        printf("SQLSetEnvAttr(ODBC version) Failed\n\n");  
        Cleanup();  
        return(9);      
    }  

    // Allocate ODBC connection handle and connect.  
    retcode = SQLAllocHandle(SQL_HANDLE_DBC, henv, &hdbc);  
    if ((retcode != SQL_SUCCESS_WITH_INFO) && (retcode != SQL_SUCCESS)) {  
        printf("SQLAllocHandle(hdbc1) Failed\n\n");  
        Cleanup();  
        return(9);  
    }  

    //数据库连接
	//第二个参数是之前配置的数据源，后面是数据库用户名和密码，如果数据源中已经指定了就直接写NULL即可。
    retcode = SQLConnect(hdbc,(SQLCHAR*)"company",SQL_NTS, NULL, SQL_NTS, NULL, SQL_NTS);
    if ((retcode != SQL_SUCCESS) && (retcode != SQL_SUCCESS_WITH_INFO)) {  
        printf("SQLConnect() Failed\n\n");  
        Cleanup();  
        return(9);  
    }  

    //分配执行语句句柄
    retcode = SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);  
    if ((retcode != SQL_SUCCESS) && (retcode != SQL_SUCCESS_WITH_INFO)) {  
        printf("SQLAllocHandle(hstmt1) Failed\n\n");  
        Cleanup();  
        return(9);  
    }  

	retcode = SQLExecDirect(hstmt,(SQLCHAR*)"use test;", SQL_NTS);
    if ((retcode != SQL_SUCCESS) && (retcode != SQL_SUCCESS_WITH_INFO)) {  
        printf("SQLExecDirect Failed: use test;\n\n");  
        Cleanup();  
        return(9);  
    }  

	SQLUBIGINT id;
	uint8_t binary[4] = {0x01, 0x02, 0x00, 0x04};
	length = sizeof(binary);
	retcode = SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY, SQL_BINARY,
        sizeof(binary), 0, binary, sizeof(binary), &length);
    if ((retcode != SQL_SUCCESS) && (retcode != SQL_SUCCESS_WITH_INFO)) {  
        printf("SQLBindParameter Failed\n\n");  
        Cleanup();  
        return(9);  
    }  

    const char *stmt = "INSERT INTO pw VALUES(6, ?);";
	retcode = SQLExecDirect(hstmt, (SQLCHAR*)stmt, SQL_NTS);
    if ((retcode != SQL_SUCCESS) && (retcode != SQL_SUCCESS_WITH_INFO)) {  
        printf("SQLExecDirect Failed: %s\n\n", stmt);  
        Cleanup();  
        return(9);
    }

    id = 2333;
    memset(binary, 0, sizeof(binary));
    retcode = SQLExecDirect(hstmt, (SQLCHAR*)"SELECT * FROM pw;", SQL_NTS);
    if ((retcode != SQL_SUCCESS) && (retcode != SQL_SUCCESS_WITH_INFO)) {  
        printf("SQLExecDirect Failed: SELECT * FROM pw;\n\n");  
        Cleanup();  
        return(9);
    }
    cout << "id\tpw\n";
    SQLBindCol(hstmt, 1, SQL_C_UBIGINT, &id, sizeof(id), &length);
    SQLBindCol(hstmt, 2, SQL_C_BINARY, binary, sizeof(binary), &length);
    while (SQL_NO_DATA != SQLFetch(hstmt)) {
        cout << id << '\t' << hex << *(uint32_t*)binary << endl;
    }

    Cleanup();

    return 0;
}
```
结果：
```
6	4000201
```
可见已经把数据写入了，只是因为我的机器是小端字节序的，所以字节序反了。
# 非定长二进制
blob系列和varbinary都可以保存非定长二进制。
[它们的区别](https://stackoverflow.com/questions/8476968/varbinary-vs-blob-in-mysql)是blob系列的数据是存储在表外的，而varbinary的数据是存储在表内的，所以blob在select的时候相当于定长域，效率比较高，但是需要额外从表外取数据。而binary在select的时候相当于变长域，会影响效率，但是可以直接从表中获取数据。

blob系列官方文档：
[TINYBLOB](https://mariadb.com/kb/en/tinyblob/): 最长255字节
[BLOB](https://mariadb.com/kb/en/blob/): 最长65535字节
[LONGBLOB](https://mariadb.com/kb/en/longblob/): 4,294,967,295字节 

varbinary文档：<https://mariadb.com/kb/en/varbinary/>

## blob
### 建表
```sql
CREATE TABLE msgcontent(
    msgid BIGINT UNSIGNED PRIMARY KEY,
    content BLOB(2000)
);
```
### 写入
关键代码：
```cpp
	uint8_t content[11] = {1, 2, 3, 4, 5, 0, 7, 8, 9, 10};
	SQLLEN contentLen = sizeof(content);
	retcode = SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY, SQL_BINARY,
        MAX_CONTENT_LEN, 0, content, sizeof(content), &contentLen);
    const char *stmt = "INSERT INTO msgcontent VALUES(3, ?);";
	retcode = SQLExecDirect(hstmt, (SQLCHAR*)stmt, SQL_NTS);
```
注意SQLBindParameter的最后一个参数如果为NULL，则相当于告诉odbc遇到NULL时停止，也就是null-terminated。如果要写入含NULL的数据，则必须指定要写入的数据长度。

### 读取
关键代码：
```cpp
    SQLUBIGINT id = 3332;
    memset(content, 0, sizeof(content));
	stmt = "SELECT * FROM msgcontent;";
    retcode = SQLExecDirect(hstmt, (SQLCHAR*)stmt, SQL_NTS);
	SQLLEN idLen;
    cout << "id\tcontent\n";
    SQLBindCol(hstmt, 1, SQL_C_UBIGINT, &id, sizeof(id), &idLen);
    SQLBindCol(hstmt, 2, SQL_C_BINARY, content, sizeof(content), &contentLen);
    while (SQL_NO_DATA != SQLFetch(hstmt)) {
		cout << id << '\t';
		if (SQL_NULL_DATA == contentLen) {
			cout << "<NULL>";
		} else {
			cout << '(' << contentLen << ')';
			for (size_t i = 0; i < contentLen; ++i) {
				printf("%02x", content[i]);
			}
		}
		cout << endl;
    }
```
### 完整代码
```cpp
#include <iostream>
#include <cstring>

#if defined(_WIN16) || defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#endif
#include <sqlext.h>

using namespace std;

#define MAX_CONTENT_LEN 2000

SQLHENV henv = SQL_NULL_HENV;  
SQLHDBC hdbc = SQL_NULL_HDBC;       
SQLHSTMT hstmt = SQL_NULL_HSTMT;  

void Cleanup() {  
    //释放语句句柄
    if (hstmt != SQL_NULL_HSTMT)  
        SQLFreeHandle(SQL_HANDLE_STMT, hstmt);  
  
    if (hdbc != SQL_NULL_HDBC) {  
        //断开数据库连接
        SQLDisconnect(hdbc);  
        //释放连接句柄
        SQLFreeHandle(SQL_HANDLE_DBC, hdbc);  
    }  
  
    //释放环境句柄句柄
    if (henv != SQL_NULL_HENV)  
        SQLFreeHandle(SQL_HANDLE_ENV, henv);  
}  

int main() {
    SQLRETURN retcode;

    // Allocate the ODBC environment and save handle.  
    retcode = SQLAllocHandle (SQL_HANDLE_ENV, NULL, &henv);  
    if ((retcode != SQL_SUCCESS_WITH_INFO) && (retcode != SQL_SUCCESS)) {  
        printf("SQLAllocHandle(Env) Failed\n\n");  
        Cleanup();  
        return(9);  
    }  

    // Notify ODBC that this is an ODBC 3.0 app.  
    retcode = SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, (SQLPOINTER) SQL_OV_ODBC3, SQL_IS_INTEGER);  
    if ((retcode != SQL_SUCCESS_WITH_INFO) && (retcode != SQL_SUCCESS)) {  
        printf("SQLSetEnvAttr(ODBC version) Failed\n\n");  
        Cleanup();  
        return(9);      
    }  

    // Allocate ODBC connection handle and connect.  
    retcode = SQLAllocHandle(SQL_HANDLE_DBC, henv, &hdbc);  
    if ((retcode != SQL_SUCCESS_WITH_INFO) && (retcode != SQL_SUCCESS)) {  
        printf("SQLAllocHandle(hdbc1) Failed\n\n");  
        Cleanup();  
        return(9);  
    }  

    //数据库连接
	//第二个参数是之前配置的数据源，后面是数据库用户名和密码，如果数据源中已经指定了就直接写NULL即可。
    retcode = SQLConnect(hdbc,(SQLCHAR*)"company",SQL_NTS, NULL, SQL_NTS, NULL, SQL_NTS);
    if ((retcode != SQL_SUCCESS) && (retcode != SQL_SUCCESS_WITH_INFO)) {  
        printf("SQLConnect() Failed\n\n");  
        Cleanup();  
        return(9);  
    }  

    //分配执行语句句柄
    retcode = SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);  
    if ((retcode != SQL_SUCCESS) && (retcode != SQL_SUCCESS_WITH_INFO)) {  
        printf("SQLAllocHandle(hstmt1) Failed\n\n");  
        Cleanup();  
        return(9);  
    }  

	retcode = SQLExecDirect(hstmt,(SQLCHAR*)"use test;", SQL_NTS);
    if ((retcode != SQL_SUCCESS) && (retcode != SQL_SUCCESS_WITH_INFO)) {  
        printf("SQLExecDirect Failed: use test;\n\n");  
        Cleanup();  
        return(9);  
    }  

	uint8_t content[11] = {1, 2, 3, 4, 5, 0, 7, 8, 9, 10};
	SQLLEN contentLen = sizeof(content);
	retcode = SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY, SQL_BINARY,
        MAX_CONTENT_LEN, 0, content, sizeof(content), &contentLen);
    if ((retcode != SQL_SUCCESS) && (retcode != SQL_SUCCESS_WITH_INFO)) {  
        printf("SQLBindParameter Failed\n\n");  
        Cleanup();  
        return(9);  
    }  

    const char *stmt = "INSERT INTO msgcontent VALUES(3, ?);";
	retcode = SQLExecDirect(hstmt, (SQLCHAR*)stmt, SQL_NTS);
    if ((retcode != SQL_SUCCESS) && (retcode != SQL_SUCCESS_WITH_INFO)) {  
        printf("SQLExecDirect Failed: %s\n\n", stmt);  
        Cleanup();  
        return(9);
    }

    SQLUBIGINT id = 3332;
    memset(content, 0, sizeof(content));
	stmt = "SELECT * FROM msgcontent;";
    retcode = SQLExecDirect(hstmt, (SQLCHAR*)stmt, SQL_NTS);
    if ((retcode != SQL_SUCCESS) && (retcode != SQL_SUCCESS_WITH_INFO)) {  
        printf("SQLExecDirect Failed: %s\n\n", stmt);  
        Cleanup();  
        return(9);
    }
	SQLLEN idLen;
    cout << "id\tcontent\n";
    SQLBindCol(hstmt, 1, SQL_C_UBIGINT, &id, sizeof(id), &idLen);
    SQLBindCol(hstmt, 2, SQL_C_BINARY, content, sizeof(content), &contentLen);
    while (SQL_NO_DATA != SQLFetch(hstmt)) {
		cout << id << '\t';
		if (SQL_NULL_DATA == contentLen) {
			cout << "<NULL>";
		} else {
			cout << '(' << contentLen << ')';
			for (size_t i = 0; i < contentLen; ++i) {
				printf("%02x", content[i]);
			}
		}
		cout << endl;
    }

    Cleanup();

    return 0;
}
```
