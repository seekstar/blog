---
title: matplotlib生成没有留白的图片
date: 2021-01-01 16:58:05
---

```py
plt.tight_layout(pad = 0)
```
如果右边界没了就
```py
plt.tight_layout(pad = 0.1)
```

例子：
原来的
```py
xx = np.arange(0, 100)
yy = xx * xx
plt.plot(xx, yy)
plt.title("Tight layout")
plt.xlabel("xxxxx")
plt.ylabel("yyyyy")
plt.show()
```

![在这里插入图片描述](matplotlib生成没有留白的图片/20210101165344452.png)

加上
```py
xx = np.arange(0, 100)
yy = xx * xx
plt.plot(xx, yy)
plt.title("Tight layout")
plt.xlabel("xxxxx")
plt.ylabel("yyyyy")
plt.tight_layout(pad = 0)
plt.show()
```

![在这里插入图片描述](matplotlib生成没有留白的图片/2021010116523616.png)

不过右边界没了。不喜欢的话把pad改成0.1

```py
xx = np.arange(0, 100)
yy = xx * xx
plt.plot(xx, yy)
plt.title("Tight layout")
plt.xlabel("xxxxx")
plt.ylabel("yyyyy")
plt.tight_layout(pad = 0.1)
plt.show()
```

![在这里插入图片描述](matplotlib生成没有留白的图片/20210101170009146.png)
