---
title: deepin安装中州韵输入法
date: 2021-03-12 15:12:38
---

# 安裝
deepin默认使用fcitx输入框架。

```shell
sudo apt install -y fcitx-rime
```

右键右下角的输入法小图标，点击`配置`，就可以看到`中州韻`了。如果没有，点击`重新启动`重启输入法，然后应该就有了。

中州韵配置文件目录在`~/.config/fcitx/rime/`。

# 切换到简体中文
中州韵默认是繁体的。切换到中州韵输入法（在某个文本输入框，按`ctrl+shift`切换），右键右下角图标，鼠标放到`方案列表`上，选择`朙月拼音`即可。

# 同步
我是用坚果云来同步的。在里面的`~/.config/fcitx/rime/installation.yaml`里设置同步路径，并更改安装ID：
```
installation_id: "Linux"
sync_dir: /home/searchstar/nutstore/software/rime
```
其中的具体路径要自己设置。注意必须是绝对路径。

然后切换到中州韵输入法（在某个文本输入框，按`ctrl+shift`切换），右键中州韵图标，选择`同步`即可把词库同步到同步目录里。如果有多台电脑，则需要手动点”同步“。

# 设置默认简体
找到`~/.config/fcitx/rime/build/luna_pinyin.schema.yaml`，在里面找到switches，在其中simplification里加上一行`reset: 1`：
```yaml
switches:
  - name: ascii_mode
    reset: 0
    states: ["中文", "西文"]
  - name: full_shape
    states: ["半角", "全角"]
  - name: simplification
    reset: 1    ##### 加上这行
    states: ["漢字", "汉字"]
  - name: ascii_punct
    states: ["。，", "．，"]
```


# 参考文献
<https://www.cnblogs.com/cstylex/p/Rime_on_Linux_Android_Mac_Windows_iOS_sync.html>
<https://blog.csdn.net/weixin_39623671/article/details/112813356>
