---
title: qt QTableWidgetItem设置文字样式
date: 2020-04-03 23:19:14
---

# 设置字体
```cpp
QFont nullFont;
nullFont.setItalic(true);
nullFont.setBold(true);
```
这里设置了斜体(italic)和粗体(bold)，字体型号为默认。

# 设置颜色
```cpp
QBrush nullColor(Qt::gray)
```
这里设置成灰色。如果想要其他颜色可以查一下```QBrush```的帮助。

# 应用到QTableWidgetItem上
```cpp
QTableWidgetItem *item = new QTableWidgetItem("NULL");
item->setFont(nullFont);
item->setBackground(nullColor);
```
这里使用了```setBackground```，也就是把```nullColor```设置为QTableWidgetItem的背景色。如果要设置文字颜色（也就是前景色），使用```setForeground```

效果：
![在这里插入图片描述](qt%20QTableWidgetItem设置文字样式/20200403231755549.png)
