---
title: Shell获取某路径所在设备的名字
date: 2021-08-23 14:43:50
---

```shell
df <your-path>
```

```
Filesystem     1K-blocks      Used Available Use% Mounted on
/dev/vdc1      419224580 119587168 299637412  29% /data
```

参考文献：<https://stackoverflow.com/questions/38615464/how-to-get-device-name-on-which-a-file-is-located-from-its-path-in-c>
