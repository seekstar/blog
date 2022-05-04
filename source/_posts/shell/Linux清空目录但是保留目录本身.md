---
title: Linux清空目录但是保留目录本身
date: 2022-05-04 18:22:08
tags:
---

## ls

```shell
ls -A | xargs rm -r
```

```text
-A, --almost-all
        显示除 "." 和 ".." 外的所有文件。
```

## find

```shell
find . -maxdepth 1 ! -path . -exec rm -r {} +
```

```text
-exec command {} +
        This  variant of the -exec action runs the specified command on the selected files, but the command
        line is built by appending each selected file name at the end; the total number of  invocations  of
        the  command will be much less than the number of matched files.  The command line is built in much
        the same way that xargs builds its command lines.  Only one instance of `{}' is allowed within  the
        command,  and it must appear at the end, immediately before the `+'; it needs to be escaped (with a
        `\') or quoted to protect it from interpretation by the shell.  The  command  is  executed  in  the
        starting  directory.   If any invocation with the `+' form returns a non-zero value as exit status,
        then find returns a non-zero exit status.  If find encounters an error, this can sometimes cause an
        immediate  exit,  so  some  pending  commands may not be run at all.  For this reason -exec my-com‐
        mand ... {} + -quit may not result in my-command actually being run.  This variant of -exec  always
        returns true.
```

参考：<https://unix.stackexchange.com/questions/584919/delete-all-files-within-a-directory-without-deleting-the-directory>
