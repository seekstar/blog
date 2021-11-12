---
title: linux odbc连接sqlite
date: 2020-05-02 20:29:13
tags:
---

参考：
[odbc使用SQLDriverConnect连接数据库](https://www.xuebuyuan.com/857766.html)
[sqliteodbc文档](http://www.ch-werner.de/sqliteodbc/html/index.html)
[Linux下通过unixODBC访问SQLite数据库](http://blog.sina.com.cn/s/blog_591f0e6e010135ov.html)
[SQLDriverConnect microsoft官方文档](https://docs.microsoft.com/en-us/sql/odbc/reference/syntax/sqldriverconnect-function?view=sql-server-ver15)

# 安装软件
```shell
sudo apt install -y sqlite3 sqlitebrowser unixodbc unixodbc-dev libsqliteodbc
```
其中sqlitebrowser可以打开sqlite的数据库文件。
# 连接
```cpp
const char connStr[] = "Driver=SQLite3;Database=test.db";
retcode = SQLDriverConnect(hdbc, NULL, (SQLCHAR*)connStr, sizeof(connStr), outConnStr, sizeof(outConnStr), &outConnStrLen, SQL_DRIVER_COMPLETE);
```
# 坑
- 注意如果第二个参数为NULL的话，最后一个参数不能为SQL_DRIVER_PROMPT，否则会连接失败。
- 连接串的Driver不能写成```SQLite3 ODBC Driver```。猜测是因为```/etc/odbcinst.ini```里只有```SQLite3```。

# 完整代码
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
	//HWND desktopHandle = GetDesktopWindow();   // desktop's window handle
	//const char connStr[] = "Driver=SQLite3 ODBC Driver;Database=/home/searchstar/test.db;Timeout=100";
	//const char connStr[] = "Driver=SQLite3 ODBC Driver;Database=test.db";
	const char connStr[] = "Driver=SQLite3;Database=test.db";
	SQLCHAR outConnStr[255];
	SQLSMALLINT outConnStrLen;
	retcode = SQLDriverConnect(hdbc, NULL, (SQLCHAR*)connStr, sizeof(connStr), outConnStr, sizeof(outConnStr), &outConnStrLen, SQL_DRIVER_COMPLETE);
	cout << outConnStrLen;
	if (outConnStrLen) {
		cout << ',' << outConnStr;
	}
	cout << endl;
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

    Cleanup();

    return 0;
}
```
输出：
```
164,DSN=;Database=test.db;StepAPI=;Timeout=;SyncPragma=;NoTXN=;ShortNames=;LongNames=;NoCreat=;NoWCHAR=;FKSupport=;Tracefile=;JournalMode=;LoadExt=;BigInt=;JDConv=;PWD=
```
