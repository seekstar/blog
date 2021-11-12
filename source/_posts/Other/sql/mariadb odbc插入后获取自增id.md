---
title: mariadb odbc插入后获取自增id
date: 2020-04-25 22:27:00
tags:
---

官方回复：<https://mariadb.com/kb/en/last_insert_id/>

# 定义表
```sql
CREATE TABLE incid (
	id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    salary INT
);

INSERT INTO incid(salary)
VALUES ("4"),
("6"),
("35432");

SELECT * FROM incid;
```
# 方法１：使用自定义函数
```sql
DELIMITER //
CREATE FUNCTION insert_sth(val int)
RETURNS bigint
BEGIN
	INSERT INTO incid(salary)
    VALUES(val);
    RETURN LAST_INSERT_ID();
END //
DELIMITER ;

SELECT insert_sth(233);
SELECT insert_sth(233);
SELECT insert_sth(233);
```
如果```SELECT insert_sth(233);```的输出是自增的说明数据库的配置完成了。

```cpp
#include <iostream>

#if defined(_WIN16) || defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#endif
#include <sqlext.h>

using namespace std;

int main() {
    SQLHENV serverhenv;
    SQLHDBC serverhdbc;
    SQLHSTMT serverhstmt;
    SQLRETURN ret;

    SQLCHAR dname[45], dno[10];

    SQLLEN length;

    //分配环境句柄
    ret = SQLAllocHandle(SQL_HANDLE_ENV,SQL_NULL_HANDLE,&serverhenv);

    //设置环境属性
    ret = SQLSetEnvAttr(serverhenv,SQL_ATTR_ODBC_VERSION,(void*)SQL_OV_ODBC3,0);
    if(!SQL_SUCCEEDED(ret))
    {
        cout<<"AllocEnvHandle error!"<<endl;
		return 0;
    }

    //分配连接句柄
    ret = SQLAllocHandle(SQL_HANDLE_DBC,serverhenv,&serverhdbc);
    if(!SQL_SUCCEEDED(ret))
    {
        cout<<"AllocDbcHandle error!"<<endl;
		return 0;
    }

    //数据库连接
	//第二个参数是之前配置的数据源，后面是数据库用户名和密码，如果数据源中已经指定了就直接写NULL即可。
    ret = SQLConnect(serverhdbc,(SQLCHAR*)"company",SQL_NTS, NULL, SQL_NTS, NULL, SQL_NTS);
    if(!SQL_SUCCEEDED(ret))
    {
        cout<<"SQL_Connect error!"<<endl;
		return 0;
    }

    //分配执行语句句柄
    ret = SQLAllocHandle(SQL_HANDLE_STMT,serverhdbc,&serverhstmt);

	SQLUBIGINT id;
	SQLINTEGER salary;
	ret = SQLExecDirect(serverhstmt,(SQLCHAR*)"use test;", SQL_NTS);
	ret = SQLExecDirect(serverhstmt, (SQLCHAR*)"select * from incid;", SQL_NTS);
    if(ret == SQL_SUCCESS || ret == SQL_SUCCESS_WITH_INFO){
        //绑定数据
        SQLBindCol(serverhstmt,1, SQL_C_UBIGINT, (void*)&id,sizeof(id), &length);
        SQLBindCol(serverhstmt,2, SQL_C_SLONG, (void*)&salary,sizeof(salary), &length);
        //将光标移动到下行,即获得下行数据
        cout << "id\t\tsalary\n";
        while(SQL_NO_DATA != SQLFetch(serverhstmt))
        {
            cout << id << "\t\t" << salary << endl;
        }
    } else {
		cout << "ERROR!\n";
	}

	ret = SQLExecDirect(serverhstmt,(SQLCHAR*)"select insert_sth(23333333);", SQL_NTS);
    if(ret == SQL_SUCCESS || ret == SQL_SUCCESS_WITH_INFO){
        //绑定数据
        SQLBindCol(serverhstmt,1, SQL_C_UBIGINT, (void*)&id, sizeof(id), &length);
        //将光标移动到下行,即获得下行数据
		SQLFetch(serverhstmt);
		cout << "The new id: " << id << endl;
    } else {
		cout << "Error\n";
	}

    //释放语句句柄
    ret=SQLFreeHandle(SQL_HANDLE_STMT,serverhstmt);
    if(SQL_SUCCESS!=ret && SQL_SUCCESS_WITH_INFO != ret)
        cout<<"free hstmt error!"<<endl;
    //断开数据库连接
    ret=SQLDisconnect(serverhdbc);
    if(SQL_SUCCESS!=ret&&SQL_SUCCESS_WITH_INFO!=ret)
        cout<<"disconnected error!"<<endl;
    //释放连接句柄
    ret=SQLFreeHandle(SQL_HANDLE_DBC,serverhdbc);
    if(SQL_SUCCESS!=ret&&SQL_SUCCESS_WITH_INFO!=ret)
        cout<<"free hdbc error!"<<endl;
    //释放环境句柄句柄
    ret=SQLFreeHandle(SQL_HANDLE_ENV,serverhenv);
    if(SQL_SUCCESS!=ret&&SQL_SUCCESS_WITH_INFO!=ret)
        cout<<"free henv error!"<<endl;

    cout << "done" << endl;

    return 0;
}
```
里面的数据源名```company```要改成你自己配置的数据源。
```shell
g++ incid.cpp -lodbc -o incid
./incid
```

# 方法２：使用存储过程
参考：
[SQLBindParameter 函数的参数解析及使用方法](https://blog.csdn.net/u013187074/article/details/52895801)
<https://bbs.csdn.net/topics/390092241>
[MySQL存储过程（PROCEDURE）](https://www.cnblogs.com/zjoe-life/p/10650378.html)
[MYSQL中如何调用带输出参数的存储过程](https://blog.csdn.net/lizzyshao/article/details/83585328)
```sql
DELIMITER $$
CREATE PROCEDURE insert_return_id(IN val int, OUT id bigint unsigned)
BEGIN
	INSERT INTO incid(salary)
    VALUES(val);
    SET id = LAST_INSERT_ID();
END
$$ DELIMITER ;

call insert_return_id(233333, @id);
select @id;
```
输出是自增的，说明存储过程写对了。

参考：<https://www.easysoft.com/developer/languages/c/examples/CallSPFindID.html>
```cpp
	id = 2333;
	SQLBindParameter(serverhstmt, 1, SQL_PARAM_OUTPUT, SQL_C_UBIGINT, SQL_BIGINT, 0, 0, &id, 0, &length);
	ret = SQLExecDirect(serverhstmt, (SQLCHAR*)("{CALL insert_return_id(23333, ?)}"), SQL_NTS);
    if(ret == SQL_SUCCESS || ret == SQL_SUCCESS_WITH_INFO){
		cout << "The new id: " << id << endl;
    } else {
		cout << "SQLExecute error\n";
	}
```
这个比方法１效率应该要高一点。

## 失败的方法
mariadb目前并不支持returning，所以下面的方法没用。下一个版本10.5就有这个功能了。

<https://stackoverflow.com/questions/5104830/retrieve-autoincrement-id-through-odbc>

```sql
INSERT INTO incid(x)
VALUES ("4"),
("6"),
("35432");

SELECT * FROM incid;

DELIMITER //
CREATE FUNCTION insert_sth(val int)
RETURNS bigint
BEGIN
	DECLARE newid bigint;
	INSERT INTO incid(x)
    VALUES(val)
    RETURNING id into newid;
    RETURN newid;
END //
DELIMITER ;
```
