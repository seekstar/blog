---
title: pandas数据框获取行数列数
date: 2021-08-20 21:32:12
---

```py
df = pd.DataFrame({'a': [1, 2, 3], 'b': [4, 5, 6]})
df.shape # 形状，格式是(行数,列数)
df.shape[0] # 行数
df.shape[1] # 列数
```

参考：<https://www.geeksforgeeks.org/python-pandas-df-size-df-shape-and-df-ndim/>
