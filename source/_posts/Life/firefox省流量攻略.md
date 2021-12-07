---
title: firefox省流量攻略
date: 2021-04-11 16:29:11
---

# 电脑版
## 关闭图片自动加载
安装一个叫做```Image Block```的插件，安装完之后插件图标会显示在插件栏，点击可以允许和禁止图片自动加载。
## 禁止音频和视频的自动播放
比如百度百科和百度经验。
Preferences -> Privacy&Security -> Permissions -> Autoplay，默认是只禁止自动播放音频，可以设置成音频和视频都禁止自动播放。
但是想看百度经验这种没有开始播放键的视频怎么办？答案是点击悬浮在视频上的小图标，进入```Picture in Picture```模式：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210411155343942.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxOTYxNDU5,size_16,color_FFFFFF,t_70)然后播放键就神奇地出现了：
![在这里插入图片描述](https://img-blog.csdnimg.cn/2021041115550589.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxOTYxNDU5,size_16,color_FFFFFF,t_70)百度经验的话还可以直接点击进度条，然后就会开始自动播放了。

# 手机版
好像只能把音频和视频关掉，没法关掉图片，```about:config```也打不开。
所以手机上还是用国产浏览器吧，一般有智能无图模式，即用流量的时候不显示图片。

# 失败的方法
本来禁止自动播放和下载音视频，最方便的是下载一个叫做```Disable HTML5 Autoplay```的插件。本来这个插件能够禁止视频自动加载的，但是好像出问题了，只能禁止视频自动播放。在某些网站比如油管，并不能防止自动播放视频。

记录一下禁止自动下载的失败尝试：
在地址栏输入```about:config```，然后回车，然后搜索```media.cache_```，会出来一堆选项：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210411154710523.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxOTYxNDU5,size_16,color_FFFFFF,t_70)把```media.cache_readahead_limit```和```media.cache_readahead_limit.cellular```都设置成0，
把```media.cache_resume_threshold```和```media.cache_resume_threshold.cellular```都设置成1。
然而并没有起效果。

# 参考文献
<https://support.mozilla.org/en-US/kb/block-autoplay>
