---
title: "ModuleNotFoundError: No module named ‘jsonrpcclient.exceptions‘"
date: 2021-09-25 21:29:37
---

jsonrpcclient当前的最新版本4.0.0好像已经没有```jsonrpcclient.exceptions```了。所以解决方案是回退到3.3.6版本：

```shell
pip3 install jsonrpcclient==3.3.6
```

参考文献：

<https://pypi.org/project/jsonrpcclient/#history>
[pip install 安装指定版本的包](https://blog.csdn.net/youcharming/article/details/51073911)
