---
title: "login: abort requested by PAM"
date: 2021-08-14 16:16:15
---

等个几分钟再试试就好了。查看dmesg，发现在输出这几条消息前卡了几分钟：

```
random : crng init done
random: 7 urandom warning(s) missed due to ratelimiting
```

于是猜测是因为初始化随机数生成器太慢了。根据这篇文章：
[Boot hang after "random: crng init done"](https://www.raspberrypi.org/forums/viewtopic.php?t=209093)

这可能是因为内核在等待鼠标移动来获取熵，里面给的解决方法是：

```shell
sudo apt install haveged
sudo systemctl enable haveged
```

参考：[Linux中使用haveged对/dev/random补熵](https://blog.csdn.net/weixin_38287155/article/details/95891886)
