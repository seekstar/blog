---
title: virtualbox安装deepin v15.11后安装增强功能
date: 2020-08-22 17:09:18
tags:
---

没有安装增强功能的话貌似不能让虚拟机自动调整分辨率。
点击

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200822170258763.png#pic_center)

结果提示挂载失败。
这一般是由于已经挂载上了。
在虚拟机里打开文件管理器

![在这里插入图片描述](https://img-blog.csdnimg.cn/2020082217052050.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxOTYxNDU5,size_16,color_FFFFFF,t_70#pic_center)

打开。

不要运行autorun.sh，会提示出错。以root运行```VBoxLinuxAdditions.run```

![在这里插入图片描述](https://img-blog.csdnimg.cn/2020082217082673.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxOTYxNDU5,size_16,color_FFFFFF,t_70#pic_center)

然后重启虚拟机就好了。
