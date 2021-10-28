---
title: systemtap embedded C 踩坑笔记
date: 2019-11-15 23:53:35
---

官方文档：
<https://sourceware.org/systemtap/langref/3_Components_SystemTap_scri.html#SECTION00045000000000000000>

# 打印
systemtap的embedded C中，不能#include <stdio.h>，也不能用printf和print。那怎么打印呢？用STAP_PRINTF。用法与printf一样。

还可以访问cript中的全局变量。
官方文档中的示例：
```c
global var
global var2[100]
function increment() %{
    /* pragma:read:var */ /* pragma:write:var */
    /* pragma:read:var2 */ /* pragma:write:var2 */
    STAP_GLOBAL_SET_var(STAP_GLOBAL_GET_var()+1); //var++
    STAP_GLOBAL_SET_var2(1, 1, STAP_GLOBAL_GET_var2(1, 1)+1); //var2[1,1]++
%}
```
注意function中头两行的注释不能删。具体意义看文档。


# 返回
获取一个task_struct的sibling的函数这样写：

```c
function GetSibling(task:long) %{
	struct task_struct *task = (struct task_struct*)STAP_ARG_task;
	return list_entry(task->sibling.next, struct task_struct, sibling);
%}
```

报错：
```
include/linux/kernel.h:908:41: 错误：expected ‘;’ before ‘(’ token
 #define container_of(ptr, type, member) ({   \
                                         ^
include/linux/list.h:374:2: 附注：in expansion of macro ‘container_of’
  container_of(ptr, type, member)
  ^
/tmp/stapcGCPg6/stap_8142d625ec4d0f2acc7a14543f578111_12083_src.c:1416:9: 附注：in expansion of macro ‘list_entry’
  return list_entry(task->sibling.next, struct task_struct, sibling);
         ^
/tmp/stapcGCPg6/stap_8142d625ec4d0f2acc7a14543f578111_12083_src.c: 在文件作用域：
cc1: 错误：无法识别的命令行选项“-Wno-tautological-compare” [-Werror]
```
看起来好像是编译器出错了。
但是原因其实是embedded C不能写return，要写STAP_RETURN。
所以要改成这样：
```c
function GetSibling(task:long) %{
	struct task_struct *task = (struct task_struct*)STAP_ARG_task;
	STAP_RETURN(list_entry(task->sibling.next, struct task_struct, sibling));
%}
```

# 打印路径
可以用d_path把struct path解析为绝对路径。centos 7中d_path的声明如下：
```c
// include/linux/dcache.h
extern char *d_path(const struct path *, char *, int);
```
其中char*是buffer的首地址，int是buffer的大小。
注意，d_path的返回值并不是传进去的buffer。直接输出buffer会输出空串。。。

正确用法示例：
```c
static char full_path[BUFFER_SIZE];
STAP_PRINTF("%s\n", d_path(&(f->f_path), full_path, BUFFER_SIZE));
```
错误用法示例：
```c
static char full_path[BUFFER_SIZE];
d_path(&(f->f_path), full_path, BUFFER_SIZE);
STAP_PRINTF("%s\n", full_path);
```
