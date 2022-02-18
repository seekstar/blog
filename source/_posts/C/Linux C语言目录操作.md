---
title: Linux C语言目录操作
date: 2021-08-02 01:05:28
---

# 系统调用(man 2)
- 打开或创建文件

```c
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int open(const char *pathname, int flags);
int open(const char *pathname, int flags, mode_t mode)
int creat(const char *pathname, mode_t mode);

int openat(int dirfd, const char *pathname, int flags);
int openat(int dirfd, const char *pathname, int flags, mode_t mode);
```

- 关闭文件

```c
#include <unistd.h>
int close(int fd);
```

- 创建目录

```c
#include <sys/stat.h>
#include <sys/types.h>
int mkdir(const char *pathname, mode_t mode);

#include <fcntl.h> /* Definition of AT_* constants */
#include <sys/stat.h>
// 在指定目录下创建目录
int mkdirat(int dirfd, const char *pathname, mode_t mode);
```

- 改变工作目录

```c
#include <unistd.h>
int chdir(const char *path);
int fchdir(int fd);
```

- 读取符号连接

符号链接不能直接open+read读取，不然会读取到其指向的文件。

```c
#include <unistd.h>
ssize_t readlink(const char *pathname, char *buf, size_t bufsiz);

#include <fcntl.h> /* Definition of AT_* constants */
#include <unistd.h>
ssize_t readlinkat(int dirfd, const char *pathname,
    char *buf, size_t bufsiz);
```

- 创建符号链接

创建符号链接不能用open+write

```c
#include <unistd.h>
int symlink(const char *target, const char *linkpath);

#include <fcntl.h> /* Definition of AT_* constants */
#include <unistd.h>
int symlinkat(const char *target, int newdirfd, const char *linkpath);
```

# glibc (man 3)

```c
struct dirent {
	ino_t          d_ino;       /* Inode number */
	off_t          d_off;       /* Not an offset; see below */
	unsigned short d_reclen;    /* Length of this record */
	unsigned char  d_type;      /* Type of file; not supported by all filesystem types */
	char           d_name[256]; /* Null-terminated filename */
};
```

d_type:

```
DT_BLK      This is a block device.
DT_CHR      This is a character device.
DT_DIR      This is a directory.
DT_FIFO     This is a named pipe (FIFO).
DT_LNK      This is a symbolic link.
DT_REG      This is a regular file.
DT_SOCK     This is a UNIX domain socket.
DT_UNKNOWN  The file type could not be determined.
```

- 打开目录

```c
#include <sys/types.h>
#include <dirent.h>
DIR *opendir(const char *name);
DIR *fdopendir(int fd);
```

- 取得目录fd

```c
#include <sys/types.h>
#include <dirent.h>
int dirfd(DIR *dirp);
```

- 遍历目录

```c
#include <dirent.h>
struct dirent *readdir(DIR *dirp);
```
当到达末尾时返回NULL。

- 关闭目录

```c
#include <sys/types.h>
#include <dirent.h>
int closedir(DIR *dirp);
```

- dirname以及basename

```c
#include <libgen.h>
char *dirname(char *path);
char *basename(char *path);
```

一般情况下的规则是先把末尾的`/`去掉，然后最后一个`/`后面的就是basename，前面的就是dirname。

特殊情况如下：


If  path  does  not  contain  a slash, dirname() returns the string "." while basename() returns a copy of path.  If path is the string "/", then both dirname() and basename() return the string "/".  If path is a null pointer or points to an  empty  string, then both dirname() and basename() return the string ".".

注意这两个函数可能会修改传进去的字符串。
