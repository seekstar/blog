---
title: linux调整音频使其与视频一致
date: 2020-02-21 15:14:09
---

# 分离出音频
参考：<http://blog.sina.com.cn/s/blog_a4b0ad3801013uhy.html>
```shell
mencoder -o history.mp3 -ovc frameno -oac mp3lame -of rawaudio history.mp4
```
这样就把mp4中的音频以mp3的形式分离出来了，方便加工。

# 分离出视频
参考：<https://baike.baidu.com/item/mencoder/9960724?fr=aladdin>
```shell
mencoder history.mp4 -nosound -ovc copy -o nosound.mp4
```

# 加工音频，使其与视频一致
## 截取音频
```shell
ffmpeg -i history.mp3 -ss 9:40 out.mp3
```
截取9分40秒后的音频

## 调速率
参考：<https://www.cnblogs.com/renhui/p/10709074.html>
```shell
ffmpeg -i history.mp3 -filter:a "atempo=0.97952" -vn out.mp3
```
-i: 指定输入文件
-vn: disable video

这样播放速率变成原来的0.97952倍。

# 截取视频
如有需要，可以截取出一段视频。
```shell
mencoder nosound.mp4 -ovc copy -ss 9:59 -o out.mp4
```

# 合并视频与音频
参考：<https://blog.csdn.net/weixin_33907511/article/details/92916772>
```shell
mencoder out.mp4 -ovc copy -oac copy -audiofile out.mp3 -o final.mp4
```
