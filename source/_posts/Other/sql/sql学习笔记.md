---
title: sql学习笔记
date: 2020-03-22 00:16:41
---

# DDL
## 各种数据类型
[mysql数据类型](https://www.jianshu.com/p/6c962030d9ee)
- decimal
参考：<https://blog.csdn.net/qq_38228254/article/details/88374713>
decimal(a,b)
 a指定小数点左边和右边可以存储的十进制数字的最大个数，最大精度38。
 b指定小数点右边可以存储的十进制数字的最大个数。小数位数必须是从 0 到 a之间的值。默认小数位数是 0。
例如decimal(3, 2)能表示的最大的数是9.99。

## 复制表
<https://www.xp.cn/b.php/79415.html>
复制表结构及数据到新表
```sql
CREATE TABLE NewTable
SELECT * FROM OldTable;
```

# DCL
## 允许普通用户以root身份登录
参考：<https://askubuntu.com/questions/766334/cant-login-as-mysql-user-root-from-normal-user-account-in-ubuntu-16-04>
```sql
UPDATE mysql.user SET plugin = 'mysql_native_password', Password = PASSWORD('secret') WHERE User = 'root';
FLUSH PRIVILEGES;
```

# DML
## SELECT语句中各成分顺序
参考：<https://blog.csdn.net/weixin_41512727/article/details/80697331>
```sql
SELECT
FROM
WHERE
GROUP BY
HAVING
ORDER BY # 默认升序。DESC表降序
LIMIT # 要检索的行的范围
```

例子
```sql
SELECT SUM(salary), dno
FROM employee
WHERE address LIKE "%广州%"
GROUP BY dno
HAVING SUM(salary) > 23000
ORDER BY SUM(salary) DESC
LIMIT 1, 2;
```
表示广州的员工总工资大于23000元的部门中，按总工资倒序排序，从1号记录（第2条）开始取出两条记录。

## 查看有哪些数据库
```sql
show databases;
```

## 查看当前数据库有哪些表
```sql
show tables;
```

## 查看某数据库有哪些表
```sql
select table_name from information_schema.tables where table_schema="DatabaseName";
```

## 取前几条数据
<https://zhidao.baidu.com/question/323511112.html>
取前10条数据
```sql
select * from TableName limit 0, 10;
```
其中0是偏移量。

## 重命名表
<https://www.cnblogs.com/huangxm/p/5736386.html>
```sql
rename table OldName to NewName;
```

## 导入数据
参考：<https://blog.csdn.net/u012318074/article/details/77478601>
查看帮助
```sql
help load data
```
```
LOAD DATA [LOW_PRIORITY | CONCURRENT] [LOCAL] INFILE 'file_name'
    [REPLACE | IGNORE]
    INTO TABLE tbl_name
    [CHARACTER SET charset_name]
    [{FIELDS | COLUMNS}
        [TERMINATED BY 'string']
        [[OPTIONALLY] ENCLOSED BY 'char']
        [ESCAPED BY 'char']
    ]
    [LINES
        [STARTING BY 'string']
        [TERMINATED BY 'string']
    ]
    [IGNORE number {LINES | ROWS}]
    [(col_name_or_user_var,...)]
    [SET col_name = expr,...]
```
例如
```sql
load data local infile 'data.csv' into table employee fields terminated by ';' OPTIONALLY ENCLOSED BY '"' ignore 1 lines;
```

## 修改密码
参考：<https://jingyan.baidu.com/article/3ea514893a2c6212e71bba02.html>
```sql
update user set password = password('你的新密码') where user = 'root';
```
