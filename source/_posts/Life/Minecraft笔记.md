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

## 一些实用机器

### 熔炉组

<https://www.bilibili.com/video/BV1Ye411E7Xs>

<https://www.bilibili.com/video/BV19ApcegEkW>


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
