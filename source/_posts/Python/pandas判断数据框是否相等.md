---
title: pandas判断数据框是否相等
date: 2021-08-20 20:53:37
---

用`equals`成员函数即可。

```py
import pandas as pd
a = pd.DataFrame({'a': [1, 2, 3], 'b': [4, 5, 6]})
b = pd.DataFrame({'a': [1, 2, 3], 'b': [4, 5, 6]})
a.equals(b)
```

```
True
```

官方文档：<https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.equals.html>
