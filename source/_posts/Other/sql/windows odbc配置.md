---
title: windows odbc配置
date: 2020-04-08 22:54:04
tags:
---

# 配置数据源
看这里：<https://blog.csdn.net/buptlihang/article/details/80275641>

# 代码
在windows下sqlext.h依赖于windows.h。详情看[我的另一篇文章](https://blog.csdn.net/qq_41961459/article/details/105399612)
示例代码：
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

    static SQLCHAR dname[45], dno[10];

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

    //执行SQL语句
    ret=SQLExecDirect(serverhstmt,(SQLCHAR*)"select dname, dno from company.department;",SQL_NTS);
    if(ret == SQL_SUCCESS || ret == SQL_SUCCESS_WITH_INFO){
        //绑定数据
        SQLBindCol(serverhstmt,1, SQL_C_CHAR, (void*)dname,sizeof(dname), &length);
        SQLBindCol(serverhstmt,2, SQL_C_CHAR, (void*)dno,sizeof(dno), &length);
        //将光标移动到下行,即获得下行数据
        cout << "dname\t\tdno\n";
        while(SQL_NO_DATA != SQLFetch(serverhstmt))
        {
            cout << dname << "\t\t" << dno << endl;
        }
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

# 编译
```shell
g++ main.cpp C:\Windows\System32\odbc32.dll -o main.exe
```

# 执行
```shell
.\main.exe
```
前面的```.\```千万不能少。

如果正确输出说明配置成功了。

# 在Qt中使用
我使用的是Qt creator。

## 设置使用utf-8编译
Qt creator的编辑器默认使用utf-8，但是编译时默认使用unicode（无语
如果不修改的话，大概率会出现这个编译错误
```
D:\git\small_projects\qt\db\dbap_company\odbc.cpp:35: error: cannot convert 'SQLCHAR* {aka unsigned char*}' to 'SQLWCHAR* {aka wchar_t*}' for argument '2' to 'SQLRETURN SQLConnectW(SQLHDBC, SQLWCHAR*, SQLSMALLINT, SQLWCHAR*, SQLSMALLINT, SQLWCHAR*, SQLSMALLINT)'
     ret = SQLConnect(serverhdbc,(SQLCHAR*)dataSource,SQL_NTS,(SQLCHAR*)user,SQL_NTS,(SQLCHAR*)passwd,SQL_NTS);
                                                                                                             ^
```
说明编译器用了UNICODE。
修改方法是在```xxxx.pro```文件中加入
```
DEFINES  -= UNICODE
```
参考：
<https://blog.csdn.net/seamanj/article/details/65861275>
<https://stackoverflow.com/questions/9770636/cannot-convert-char-to-wchar-qt-c>

vs里的修改方法：<https://blog.csdn.net/bzkmjczldxl/article/details/52053404>

## 链接odbc
我这里使用的是odbc32
在```xxxx.pro```中加入
```
LIBS += -lodbc32
```

## 总结
判断操作系统类型看[我的另一篇文章](https://blog.csdn.net/qq_41961459/article/details/105401011)
在```xxxx.pro```中加入
```
win32 {
    DEFINES  -= UNICODE
    LIBS += -lodbc32
}
unix {
    LIBS += -lodbc
}
```
即可同时支持windows和linux。

# 其他问题
## 查询结果乱码
把odbc的数据源驱动从unicode版切换成ansi版
![在这里插入图片描述](windows%20odbc配置/20200409111022529.png)
## 执行sql语句时odbc返回HY000错误
参考：<https://blog.csdn.net/jiazhangyierzi/article/details/81215831>
一般是因为数据库的字符集的问题。把数据库中所有的列的字符集都换成utf8即可。
### 在workbench中修改列字符集
在这里把所有列的charset修改成uft8
![在这里插入图片描述](windows%20odbc配置/20200409111836367.png)
![在这里插入图片描述](windows%20odbc配置/2020040911264782.png)

### 通过命令
似乎可以一次性把所有字段都设置为utf8（我没试过）
<https://jingyan.baidu.com/article/574c521976eea16c8d9dc1a1.html>
