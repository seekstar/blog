---
title: Markdown quote嵌套
date: 2022-06-02 12:06:26
tags:
---

嵌套的quote结束之后要留一个空行：

```md
>a
>>b
>>b
>
>c
```

效果：

>a
>>b
>>b
>
>c

如果不留空行，后面被quote的内容就仍然会被加入到嵌套的quote里：

```md
>a
>>b
>>b
>c
```

效果：

>a
>>b
>>b
>c

来源：<https://commonmark.org/help/tutorial/05-blockquotes.html>
