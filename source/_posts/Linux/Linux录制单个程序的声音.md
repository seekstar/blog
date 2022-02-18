---
title: Linux录制单个程序的声音
date: 2022-01-27 23:36:15
tags:
---

列出正在发出声音的程序：

```shell
pacmd list-sink-inputs
```

主要看`media.name`，找到要录制的是哪个，比如这里就是index为2358的那个。然后：

```shell
INDEX=2358
pactl load-module module-null-sink sink_name=steam
pactl move-sink-input $INDEX steam
```

这个时候这个程序的声音会从扬声器消失。然后开始录制：

```shell
parec -d steam.monitor | oggenc -b 192 -o steam.ogg --raw -
```

注意如果暂停再重新播放的话，index可能会变，不过好像不用重新`move-sink-input`？

可以用Audacity把没用的部分删掉。先用鼠标划出要删掉的部分，可以用键盘精确设置范围，然后再点上面的剪刀图案来把这个区域剪掉。最后导出即可。

如果ogg的时长是错的：

```shell
sox xxx.ogg xxx.mp3
```

参考文献：

<https://askubuntu.com/questions/60837/record-a-programs-output-with-pulseaudio>

[audacity剪切音乐教程](https://tech.wmzhe.com/article/14979.html)
