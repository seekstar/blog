---
title: Markdown quote嵌套
date: 2022-06-02 12:06:26
tags:
---

嵌套的quote的前面和后面都要留一个空行：

```md
>a
>
>>b
>>b
>
>c
```

效果：

>a
>
>>b
>>b
>
>c

如果前面或者后面不留空行，显示就会不正常。后面不留空行：

```md
>a
>
>>b
>>b
>c
```

效果：

>a
>
>>b
>>b
>c

前面不留空行：

```md
>a
>>b
>>b
>
>c
```

>a
>>b
>>b
>
>c

不过vscode自带的markdown预览貌似允许前面不留空行。

参考：<https://commonmark.org/help/tutorial/05-blockquotes.html>
