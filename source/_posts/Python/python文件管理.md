---
title: python文件管理
date: 2021-07-22 14:34:19
---

用到了如下模块：

```py
import os, shutil
```

其中`shutil`是`shell util`的缩写。官方文档：<https://docs.python.org/3/library/shutil.html>

## `os.path`

文档：<https://docs.python.org/3/library/os.path.html>

- 判断文件是否存在 [os.path.exists](https://docs.python.org/3/library/os.path.html#os.path.exists)

- 是否为目录 [os.path.isdir(path)](https://docs.python.org/3/library/os.path.html#os.path.isdir)

- [os.path.basename](https://docs.python.org/3/library/os.path.html#os.path.basename)

## cd

`os.chdir(path)`

它只是libc的`chdir`的一个wrapper，行为类似于`cd -P`，在路径中有symbolic link的时候可能会有问题。

```text
      -P        use the physical directory structure without following
                symbolic links: resolve symbolic links in DIR before
                processing instances of `..'
```

参考：<https://bugs.python.org/issue29635>

## 创建目录

[os.mkdir](https://docs.python.org/3/library/os.html#os.mkdir)

`os.makedirs`，相当于shell里的`mkdir -p`，但是如果已经存在则会报错。
`os.makedirs(dirname, exist_ok=True)`使得即使目录存在也不报错。

## 复制文件

`shutil.copyfile`

## 移动

`shutil.move`

## 其他

[python遍历目录下的所有文件和目录详细介绍](https://blog.csdn.net/sinat_29957455/article/details/82778306)

检查文件是不是块设备：<https://www.systutorials.com/how-to-check-whether-a-file-of-a-given-path-is-a-block-device-in-python/>
