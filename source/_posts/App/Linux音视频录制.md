---
title: Linux音视频录制
date: 2022-08-24 12:57:45
tags:
---

## 录屏

参考：<https://democreator.wondershare.com/screen-recorder/linux-screen-recorder.html>

### OBS Studio

```shell
sudo pacman -S obs-studio
```

可以把不同来源的音频录制到不同的audio track：<https://www.reddit.com/r/obs/comments/11pnn29/how_to_separate_audio_tracks_when_recording/>

### vokoscreenNG

可以保存为很多种格式。但是不能把多个来源的音频保存到独立的track。而且录长视频录到后面声音和画面都会变得特别卡。

### Kazam

不知道为什么speaker的声音录不进去。

## 录音

Audacity：不错，而且可以剪辑。

Ardour：太复杂了。

参考：<https://linuxhint.com/best-linux-audio-recorder/>

相关：{% post_link CLI/'Linux录制单个程序的声音' %}

## 剪辑

kdenlive
不知道为什么不能把大的mkv文件导入到素材库。提示要转码，但点击转码之后又没反应。

### OpenShot

好像只有stereo（立体声）模式，没有mono模式。可以编辑好之后用Audacity转成mono模式

#### 精确剪切

右键playhead -> slice all

来源：<https://www.reddit.com/r/OpenShot/comments/dd8epj/cut_at_exact_point/>

### Kdenlive

#### 精确剪切

shift+r 在playhead处切割。当前帧会分配到后一个clip。

来源：<https://www.reddit.com/r/kdenlive/comments/xzdh4n/how_to_cut_this_clip_exactly_at_this_point_in/>

#### 剪辑特定轨道

默认是组合剪辑，也就是所有轨道一起剪辑。如果需要剪辑特定轨道，可以先左键选择轨道之后`ctrl+shift+g`取消组合剪辑，然后就可以左键选择特定轨道了。

#### 导出

项目->导出，或者ctrl+回车

#### 存在的问题

轨道太多的话不知道怎么滚动到下面的轨道。这里说按shift再滚动：<https://www.reddit.com/r/kdenlive/comments/s87975/cannot_scroll_down_kdenlive_tracks/>。但我试了还是不行。只能把多余的轨道删掉，并且最小化轨道。

### Shotcut

长视频导入进去会OOM
