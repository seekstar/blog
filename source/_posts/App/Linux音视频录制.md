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

#### 创建只有文字的片段

在项目素材箱右键，选择`添加字幕剪辑`，然后就可以编辑文字了。在右边可以设置持续时间。完成之后点击`创建字幕`，回到主界面之后就可以在项目素材箱看到这个片段了。然后把这个片段拖动到下面的视频轨道即可。

#### 自动字幕

项目->字幕->添加字幕

项目->字幕->语音识别

如果没有安装语音模型的话，点击`请安装语音识别模型`下面的`配置`->`添加模型`，在输入框里粘贴`https://alphacephei.com/vosk/models/vosk-model-small-cn-0.22.zip`，也可以在这里挑选适合你的模型：<https://alphacephei.com/vosk/models>。把模型URL粘贴进去之后点击确定，Kdenlive就会自动把模型下载下来了。如果缺少python依赖的话也可以直接点击安装依赖的按钮，Kdenlive会自动安装。然后点击`应用`。之后可以在 设置->配置Kdenlive->语音转文字 里添加更多模型。更大的那个中文模型不知道为什么我这里会让kdenlive崩溃。

回到主界面之后，把时间轴下面，字幕轨道上面的灰色的选择条（可能有点短，要ctrl+滚轮放大来找）拖动到覆盖整个项目，然后选中语音所在的音轨里随便哪个clip，项目->字幕->语音识别，选择要使用的模型，选择`时间轴区段（所选轨道）`，点击`处理`，就开始语音识别了。弹出`字幕已导入`的提示之后，点击`关闭`，回到主界面就能看到生成的字幕了。

参考：<https://www.youtube.com/watch?v=_PVsZc5vdtc>

#### 导出

项目->导出，或者ctrl+回车

#### 存在的问题

轨道太多的话不知道怎么滚动到下面的轨道。这里说按shift再滚动：<https://www.reddit.com/r/kdenlive/comments/s87975/cannot_scroll_down_kdenlive_tracks/>。但我试了还是不行。只能把多余的轨道删掉，并且最小化轨道。

### Shotcut

长视频导入进去会OOM
