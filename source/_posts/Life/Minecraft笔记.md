---
title: Minecraft笔记
date: 2025-02-09 16:40:02
tags:
---

## 常用命令

- 永昼: `gamerule doDaylightCycle false`

- 晴天: `weather clear`

- 让天气不再变化: `gamerule doWeatherCycle false`

## 鱼骨挖矿最优间距

煤：6格

钻石：3格

总的来说，可以先隔7格，之后再隔3格。

来源：<https://m.gaoshouyou.com/wdsj/gonglue/102633>

## 老版本的最佳挖矿高度

Y=11

## 1.20以后的最佳挖矿高度

- 煤炭 Y=95 & 136

- 铜矿 Y=48

- 铁矿 Y=16 & 232

- 青金石 Y=0

- 黄金 Y=-16或者恶地，跟煤矿一样普遍

- 钻石 Y=-58。但Y=-54是熔岩池水平面，更好挖。

- 红石 Y=-58。但Y=-54是熔岩池水平面，更好挖。

- 所有矿物的综合最佳高度是Y=9，没有深板岩

- 远古残骸 Y=14，在区块边缘生成概率更高

下界金矿石最好用精准采集挖然后放熔炉烧，可以直接烧出一个金锭。

来源：<https://www.bilibili.com/video/BV1bV411u7nK/>

## 绿宝石交易选项

完整列表：<https://zh.minecraft.wiki/w/交易#村民职业与交易选项>

### 盔甲匠（高炉）

（学徒）4铁 -> 1绿宝石

（专家）19-33绿宝石 -> 钻石护腿

（专家）13-27绿宝石 -> 钻石靴子

（大师）13-27绿宝石 -> 钻石头盔

（大师）21-35绿宝石 -> 钻石胸甲

### 工具匠（锻造台）

（学徒）4铁 -> 1绿宝石

4绿宝石 -> 钻石锄

17-31绿宝石 -> 钻石斧

10-24绿宝石 -> 钻石锹

18-32绿宝石 -> 钻石镐

### 武器匠（砂轮）

（学徒）4铁 -> 1绿宝石

### 农民（堆肥桶）

（新手）20小麦 -> 1绿宝石

（学徒）6南瓜 -> 1绿宝石

（老手）4西瓜 -> 1绿宝石

### 石匠（切石机）

（学徒）石头20 -> 1绿宝石

### 牧师（酿造台）

（新手）1绿宝石 -> 2红石粉

（老手）4绿宝石 -> 1萤石

（专家）5绿宝石 -> 1末影珍珠

### 图书管理员（讲台）

（新手）24纸 -> 1绿宝石

（老手）1绿宝石 -> 4玻璃

（大师）20绿宝石 -> 1命名牌

### 制图师（制图台）

（新手）24纸 -> 1绿宝石

（学徒）海洋探险家地图

（老手）林地探险家地图

（老手）试炼探险家地图

（专家）7绿宝石 -> 1物品展示框

### 屠夫（烟熏炉）

（学徒）1绿宝石 -> 5熟猪排

### 制箭师（制箭台）

（新手）1绿宝石 -> 16箭

### 牧羊人（织布机）

染料 -> 1绿宝石

### 皮匠（炼药锅）

（大师）6绿宝石 -> 1鞍

## 附魔组合

盔甲建议3个保护IV+1个火焰保护IV。

荆棘III(两个II敲在一起): 反弹伤害会消耗耐久度，不建议

铁砧费用计算：<https://www.bilibili.com/video/BV1Xz4y1W7k5>

把附魔书敲到没有附魔的装备上会让装备的铁砧操作次数+1

### 剑

锋利V/亡灵杀手V(两个IV敲在一起) + 耐久III + 经验修补 + 横扫之刃III(仅Java版) + 抢夺III

### 斧

锋利V/亡灵杀手V(两个IV敲在一起) + 耐久III + 经验修补

### 弓

力量V(两个IV敲在一起) + 冲击II + 耐久III + 无限/经验修补 + 火矢

### 头盔

火焰保护IV/保护IV + 耐久III + 经验修补 + 水下速掘 + 水下呼吸III

### 胸甲/护腿

火焰保护IV/保护IV + 耐久III + 经验修补

### 靴子

火焰保护IV/保护IV + 耐久III + 经验修补 + 摔落缓冲IV + 深海探索者III + 灵魂疾行III + 迅捷潜行III

可选：冰霜行者II

## 一些实用机器

### 熔炉组

<https://www.bilibili.com/video/BV1Ye411E7Xs>

<https://www.bilibili.com/video/BV19ApcegEkW>

### 全自动羊毛机

<https://www.bilibili.com/video/BV16D4y127CK>

### 半自动骨粉全作物

<https://www.bilibili.com/video/BV1Kb411U7kX>

## 地图编辑器

### MCA Selector

区块编辑器。可以删除不怎么用的区块，减少存档磁盘占用。

#### Linux

建议用Nix包管理器安装：

```shell
nix-env -iA nixpkgs.mcaselector
```

然后在终端运行`mcaselector`即可。

直接运行它的jar包会报JavaFX缺失的错误，不知道怎么修。

#### 文档

<https://github.com/Querz/mcaselector/wiki>

拖动：按住中键

### Amulet

#### Windows

直接下载即可：<https://github.com/Amulet-Team/Amulet-Map-Editor/releases>

#### Linux

```shell
pip3 install amulet-map-editor
```

然后终端运行`amulet_map_editor`

在Linux上按钮会闪：<https://github.com/Amulet-Team/Amulet-Map-Editor/issues/127>

#### 快捷键

`tab`在2D编辑器（俯视）和3D编辑器之间切换。

## 第三方启动器

强烈推荐`Prism Launcher`: Minecraft launcher with ability to manage multiple instances

可以玩CurseForge的整合包，比如RLCraft。可以挑选loader，例如fabric和forge，而且还可以直接在里面搜索安装mod，非常方便。

安装：

```shell
# ArchLinux
sudo pacman -S prismlauncher
```

Instance的路径：`~/.local/share/PrismLauncher/instances/`

### 使用独显

设置 -> Minecraft -> 微调 -> 使用独显

然后在游戏内按F3，在`Display:`部分就能看到独显了。

## MOD

### Litematica

常用的投影模组

#### 创建投影

拿着木棍，ctrl+鼠标滚轮切换到选择模式，左键设置点1的位置，右键设置点2的位置，两个点确定的立方体就是选中的区域。

然后按`m`进入投影菜单，然后选择`选区编辑器`

可以在选区编辑器里微调两个点的位置。也可以在游戏界面按alt+滚轮调整位置，朝哪个方向就往哪个方向移动。比如朝前的话，滚轮向上就往前移动，向后就往后移动。朝上的话，滚轮向上就往上移动，向下就往下移动。

调好选区之后，在选区编辑器里的`选择名称`里写上原理图的名字，点击`确定`，然后点击`保存原理图`，然后在上面的框里再写一下名字，如果机器不需要实体的话，建议勾选`忽略实体`，然后点击`保存原理图`，即可把选区中的东西保存为投影文件。

#### （创造模式）粘贴投影

按`m`进入投影菜单，再进入`配置菜单`，或者`m+c`直接进入配置菜单，选择`热键`，找到`执行操作`，点击右边的按键设置快捷键，我个人是`Enter`，也可以设置成别的键，只要没有跟别的快捷键冲突即可（字是白色说明没冲突，黄色说明冲突了）。然后按ECS键回到游戏界面。

按`m`进入投影菜单，选择`加载原理图`，选择要粘贴的投影文件，勾选`创建放置`，点击`加载原理图`，然后点击右下角的`投影菜单`，按ECS键回到游戏界面，用alt+滚轮调整投影位置。

注意，如果选中的区域内已经有一些方块，粘贴的时候不会把这些方块替换掉。

#### 替换方块

按`m+c`进入配置菜单，选择`热键`，点击放大镜的图标，搜索`tool`，设置`toolSelect | 主方块选择`的快捷键，用来指定要替换成的方块，默认是`LEFT_ALT`，我直接用的默认值。再设置`toolSelect | 副方块选择`的快捷键了，用来指定被替换的方块，默认是`LEFT_SHIFT`，我改成了`LEFT_CONTROL`，这样创造模式选择方块的时候不会下降。

然后手拿木棍ctrl+滚轮调到选择模式，选中需要替换方块的区域。然后ctrl+滚轮调到`替换方块`模式，按住`副方块选择`的快捷键（我这里是`LEFT_CONTROL`），鼠标中键点击被替换的方块。然后按住`主方块选择`的快捷键（我这里是`LEFT_ALT`），鼠标中键点击要替换成的方块。这时左下角可以看到：

```text
方块：<要替换成的方块>
替换：<被替换的方块>
```

然后按`执行操作`的快捷键，我是`Enter`。

参考：[基于模式4的替换投影方块状态【mc投影litematica模组教程】](https://www.bilibili.com/video/BV1434y1V7ev)

#### 参考

[投影详细教学](https://www.mcmod.cn/post/1308.html)

[我的世界模组(litematica)保姆级教程-操作篇](https://www.bilibili.com/video/BV1m24y1F7o8)

[一顿饭学会Litematica常规操作](https://www.bilibili.com/video/BV1yk4y1y7Cj)

## 光影

主流光影基本上要么依赖Optifine要么依赖Iris。

Iris只支持Fabric和Neoforge: <https://www.curseforge.com/minecraft/mc-mods/irisshaders/files/all?page=1&pageSize=20>

所以如果整合包用的是Forge（比如RLCraft），就只能用Optifine了。

Optifine是闭源的，可能由于重分发许可的问题只能从官网下载：<https://optifine.net/downloads>

找到自己的Minecraft版本之后，点击`Mirror`下载，把OptiFine_xxx.jar放到mods文件夹下面即可。

参考: <https://prismlauncher.org/wiki/getting-started/installing-optifine/#installing-optifine-on-top-of-a-modloader>

### BSL Sharders

这里以目前的最新版v8.4.02.2为例。

视频设置 -> 光影 -> 选中BSL_xxx.zip -> 光影设置

#### 解决雾蒙蒙的问题

```text
Environment --- Fog --- Overworld Fog Density, Nether Density, End Density 全部调成0
             |- Weather Opacity 调到最低
Camera --- Bloom 关
```

#### 解决中午沙子晃眼睛的问题

```text
Color --- Lighting Color --- Light (Day) --- Intensity 调到 1.1
```

#### 参考

[渣机最爱光影BSL新版去白内障设置方法-我的世界](https://www.bilibili.com/video/BV1pV4y1r7Kg)
