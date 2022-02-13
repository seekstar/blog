---
title: linux mariadb odbc
date: 2020-03-27 18:11:13
---

参考：
<https://blog.csdn.net/mei777387/article/details/75331428>
<https://www.cnblogs.com/pycode/p/9495793.html>

mariadb与mysql非常像，甚至安装mariadb后可以使用mysql命令运行mariadb。

# 安装软件
```shell
sudo apt install -y mariadb-server mariadb-client
```
我这里安装的是mariadb19。如果是mariadb18，请把下面的mariadb19换成mariadb18。

# 设置密码
刚安装是没有密码的。先设置密码
```shell
sudo -s
```

```shell
mysql
```

```sql
UPDATE mysql.user SET plugin = 'mysql_native_password', Password = PASSWORD('a') WHERE User = 'root';
FLUSH PRIVILEGES;
```
这里密码设置成了```a```

以后就可以使用
```shell
mysql -u root -p
```
登录了

# 安装unixodbc
```shell
sudo apt install -y unixodbc
```
测试一下是否安装成功
```shell
odbcinst -j
```
成功：
![在这里插入图片描述](linux%20mariadb%20odbc/2020032715473971.png)
失败的话看参考链接。

# 安装MariaDB Connector/ODBC
<https://downloads.mariadb.org/connector-odbc/+releases/>

这是目前的[最新版本](https://downloads.mariadb.com/Connectors/odbc/connector-odbc-3.1.6/mariadb-connector-odbc-3.1.6-ga-debian-x86_64.tar.gz)

然后cd到下载目录
```shell
mkdir mariadb-connector-odbc-3.1.6-ga-debian-x86_64
tar -zxvf mariadb-connector-odbc-3.1.6-ga-debian-x86_64.tar.gz -C mariadb-connector-odbc-3.1.6-ga-debian-x86_64
cd mariadb-connector-odbc-3.1.6-ga-debian-x86_64/lib
sudo cp libmaodbc.so /lib/x86_64-linux-gnu/mariadb19/
```

# 编辑/etc/odbcinst.ini
```
# Example driver definitions
# Driver from the postgresql-odbc package
# Setup from the unixODBC package

# Driver from the mysql-connector-odbc package
# Setup from the unixODBC package
[mariadb]
Description = ODBC for mariadb
Driver = /usr/lib/x86_64-linux-gnu/mariadb19/libmaodbc.so
Setup = /usr/lib/x86_64-linux-gnu/mariadb19/libmaodbc.so
FileUsage = 1
```
这里实际上是定义了一个叫做mariadb的driver。
# 编辑/etc/odbc.ini
```
[dbexp2]
Description = mariadb
Driver = mariadb
Server = 127.0.0.1
Port = 3306
USER = root
Password = a
CHARSET = UTF8
```
# 测试
```shell
isql dbexp2 -v
```
大概率会出错。
```
[01000][unixODBC][Driver Manager]Can't open lib '/usr/lib/x86_64-linux-gnu/mariadb19/libmaodbc.so' : file not found
[ISQL]ERROR: Could not SQLConnect
```
其实是因为libmaodbc.so的依赖不满足。
看看它的依赖：
```shell
ldd /usr/lib/x86_64-linux-gnu/mariadb19/libmaodbc.so
```
输出：
```
	linux-vdso.so.1 (0x00007ffe223e4000)
	libodbcinst.so.2 => /lib/x86_64-linux-gnu/libodbcinst.so.2 (0x00007f78c000a000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f78bfe87000)
	libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f78bfe82000)
	libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f78bfe61000)
	libssl.so.1.0.0 => not found
	libcrypto.so.1.0.0 => not found
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f78bfc9e000)
	libltdl.so.7 => /lib/x86_64-linux-gnu/libltdl.so.7 (0x00007f78bfc93000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f78c04d0000)
```
可以看到找不到libssl.so.1.0.0和libcrypto.so.1.0.0。
解决方案：<https://blog.csdn.net/qq_41961459/article/details/105141622>
再查看依赖
```
linux-vdso.so.1 (0x00007fff634cb000)
	libodbcinst.so.2 => /lib/x86_64-linux-gnu/libodbcinst.so.2 (0x00007fe427f12000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fe427d8f000)
	libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fe427d8a000)
	libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fe427d69000)
	libssl.so.1.0.0 => /lib/x86_64-linux-gnu/libssl.so.1.0.0 (0x00007fe427b08000)
	libcrypto.so.1.0.0 => /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 (0x00007fe42770b000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fe427548000)
	libltdl.so.7 => /lib/x86_64-linux-gnu/libltdl.so.7 (0x00007fe42753d000)
	/lib64/ld-linux-x86-64.so.2 (0x00007fe4283d9000)
```
已经满足了。

再跑一遍
```shell
isql dbexp2 -v
```
成功：
```
searchstar@searchstar-debian10-minimum:~/SetupFiles$ isql dbexp2 -v
+---------------------------------------+
| Connected!                            |
|                                       |
| sql-statement                         |
| help [tablename]                      |
| quit                                  |
|                                       |
+---------------------------------------+
SQL> 
```

# 在C/C++中使用
参考：
<https://blog.csdn.net/techtitan/article/details/6774859>
<https://blog.csdn.net/qq_40861091/article/details/89345860>

先安装头文件
```shell
sudo apt install -y unixodbc-dev
```
之后相关头文件就在```/usr/include/```下了。编译的时候不需要用```-I```选项。

如果还需要mysql的头文件
```shell
sudo apt install -y default-libmysqlclient-dev
```
之后相关头文件就在```/usr/include/mysql```下了。编译的时候需要用```-I"/usr/include/mysql"```，或者代码里头文件前加```mysql/```，例如```#include <mysql/mysql.h>```

建议使用纯odbc，以保证可移植性。

示例：
（代码参考自<https://blog.csdn.net/buptlihang/article/details/80275641>）
```cpp
#include <iostream>
#include <sqlext.h>

using namespace std;

int main() {
    sqlhenv serverhenv;
    sqlhdbc serverhdbc;
    sqlhstmt serverhstmt;
    sqlreturn ret;

    static sqlchar dname[45], dno[10];

    sqllen length;

    //分配环境句柄
    ret = sqlallochandle(sql_handle_env,sql_null_handle,&serverhenv);

    //设置环境属性
    ret = sqlsetenvattr(serverhenv,sql_attr_odbc_version,(void*)sql_ov_odbc3,0);
    if(!sql_succeeded(ret))
    {
        cout<<"allocenvhandle error!"<<endl;
		return 0;
    }

    //分配连接句柄
    ret = sqlallochandle(sql_handle_dbc,serverhenv,&serverhdbc);
    if(!sql_succeeded(ret))
    {
        cout<<"allocdbchandle error!"<<endl;
		return 0;
    }

    //数据库连接
    ret = sqlconnect(serverhdbc,(sqlchar*)"dbexp2",sql_nts,(sqlchar*)"root",sql_nts,(sqlchar*)"a",sql_nts);//第二个参数是之前配置的数据源，后面是数据库用户名和密码
    if(!sql_succeeded(ret))
    {
        cout<<"sql_connect error!"<<endl;
		return 0;
    }

    //分配执行语句句柄
    ret = sqlallochandle(sql_handle_stmt,serverhdbc,&serverhstmt);

    //执行sql语句
    ret=sqlexecdirect(serverhstmt,(sqlchar*)"select dname, dno from company.department;",sql_nts);
    if(ret == sql_success || ret == sql_success_with_info){
        //绑定数据
        sqlbindcol(serverhstmt,1, sql_c_char, (void*)dname,sizeof(dname), &length);
        sqlbindcol(serverhstmt,2, sql_c_char, (void*)dno,sizeof(dno), &length);
        //将光标移动到下行,即获得下行数据
        cout << "dname\t\tdno\n";
        while(sql_no_data != sqlfetch(serverhstmt))
        {
            cout << dname << "\t\t" << dno << endl;
        }
    }

    //释放语句句柄
    ret=sqlfreehandle(sql_handle_stmt,serverhstmt);
    if(sql_success!=ret && sql_success_with_info != ret)
        cout<<"free hstmt error!"<<endl;
    //断开数据库连接
    ret=sqldisconnect(serverhdbc);
    if(sql_success!=ret&&sql_success_with_info!=ret)
        cout<<"disconnected error!"<<endl;
    //释放连接句柄
    ret=sqlfreehandle(sql_handle_dbc,serverhdbc);
    if(sql_success!=ret&&sql_success_with_info!=ret)
        cout<<"free hdbc error!"<<endl;
    //释放环境句柄句柄
    ret=sqlfreehandle(sql_handle_env,serverhenv);
    if(sql_success!=ret&&sql_success_with_info!=ret)
        cout<<"free henv error!"<<endl;

    cout << "done" << endl;

    return 0;
}
```
因为之前数据源中已经定义了用户名和密码，所以这里用户名和密码可以省掉，即
```cpp
ret = sqlconnect(serverhdbc,(sqlchar*)"dbexp2",sql_nts,(sqlchar*)"root",sql_nts,(sqlchar*)"a",sql_nts);//第二个参数是之前配置的数据源，后面是数据库用户名和密码
```
可以换成
```cpp
ret = SQLConnect(serverhdbc,(SQLCHAR*)"dbexp2",SQL_NTS, NULL, 0, NULL, 0);
```
```shell
g++ main.cpp -lodbc -o main
./main
```
输出：
```
dname		dno
Economy Department		000
Sales Department		001
Human Resource Department		010
Produce Department		011
Research Department		100
done
```
