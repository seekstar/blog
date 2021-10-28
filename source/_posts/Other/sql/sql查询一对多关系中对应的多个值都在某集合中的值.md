---
title: sql查询一对多关系中对应的多个值都在某集合中的值
date: 2020-03-29 01:02:28
---

例如找到所有选的课都在课程表中的学生。
假如课程表中所有课的集合为cs，学生的表为stu，stu.id是学生姓名，stu.c是学生选的课。

思路：不存在某门课不在课程表中。
```sql
select id
from (
	select DISTINCT id
	from stu
) ids
where not exists (
	select c
	from stu
	where c not in (select * from cs) and
		stu.id = ids.id
);
```

测试
```sql
create database test;
use test;
create table stu (
	id char(10),
	c char(10)
);
create table cs (
	c char(10)
);
insert into stu
values
("1", "1"),
("1", "2"),
("2", "1"),
("2", "2"),
("3", "1"),
("3", "3"),
("4", "1"),
("4", "2"),
("4", "3"),
("5", "3");
insert into cs
values ("1"), ("2");
```
然后跑一遍查询，输出
```
+------+
| id   |
+------+
| 1    |
| 2    |
+------+
```

复杂度分析：
假设有x名学生，每名学生选了y门课，课程表中有z门课。
```sql
select DISTINCT id
from stu
```
这个子查询的复杂度为O(xy)。因为stu中有```xy```行，然后扫一遍，用哈希表除重。
```sql
select c
from stu
where c not in (select * from cs) and
	stu.id = ids.id
```
这个子查询跑一次的复杂度为O(y)，因为只需要查询一个学生的信息，每个学生选了y门课，在哈希表中找这y门课即可。
这个子查询要跑x次，所以跑这个子查询总共的复杂度为O(xy)。
综上，总复杂度为O(xy)。
