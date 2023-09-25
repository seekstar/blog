---
title: Linux shell向named pipe写入时不自动EOF
date: 2023-09-25 21:44:51
tags:
---

`mkfifo 文件名`即可创建pipe文件：

```shell
mkfifo p
cat p &
echo test > p
```

`cat p`就会打印出`test`

但是如果有两个echo:

```shell
mkfifo p
cat p &
echo 111 > p
echo 222 > p
```

`cat p`会打印出`111`，但是紧接着就因为读到了EOF而退出了，因此`echo 222 > p`会卡住。

这是因为当pipe文件的最后一个writer关闭之后，就会自动发送一个EOF。而`echo 111 > p`完成之后，`p`就没有writer了，因此会自动发送一个EOF。

因此如果要让`echo 111 > p`之后不要发送EOF，只需要保持pipe文件至少有一个writer。我们可以在一开始就`exec 3>p`，把shell的3号file descriptor重定向到pipe文件，这样它就一直有一个writer，最后写入完毕需要EOF时，`exec 3>&-`将3号file descriptor关闭即可：

```shell
mkfifo p
cat p &
exec 3>p
echo 111 > p
echo 222 > p
exec 3>&-
```

来源：<https://stackoverflow.com/questions/14066992/what-does-minus-mean-in-exec-3-and-how-do-i-use-it>

## 失败的尝试

如果`cat p &`没有放在前面的话，`exec 3>p`会卡住，因为没有reader。如果需要把reader放在后面执行，可以用`exec 3<>p`，让它既是reader又是writer：

```shell
mkfifo p
exec 3<>p
cat p &
echo 111 > p
echo 222 > p
exec 3>&-
```

但是很奇怪的是`exec 3>&-`似乎并没有成功关闭file descriptor，`cat p &`并没有停止运行。
