---
title: python文件管理
date: 2021-07-22 14:34:19
---

用到了如下模块：

```py
import os, shutil
```

其中```shutil```是```shell util```的缩写。

- 创建目录
```os.makedirs```，相当于shell里的```mkdir -p```，但是如果已经存在则会报错。
```os.makedirs(dirname, exist_ok = True)```使得即使目录存在也不报错。

- 复制文件
```shutil.copyfile```

- 移动
```shutil.move```

- 判断文件是否存在
```os.path.exists```

- 其他
[python遍历目录下的所有文件和目录详细介绍](https://blog.csdn.net/sinat_29957455/article/details/82778306)
