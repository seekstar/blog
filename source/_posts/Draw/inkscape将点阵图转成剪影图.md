---
title: inkscape将点阵图转成剪影图
date: 2021-11-25 18:58:12
tags:
---

先用GIMP将不要的部分擦掉，使得图像只有要变成剪影图的部分和白色的底色。然后打开inkscape，把点阵图的文件拖进去，然后调到合适的尺寸，记得要点击上面的锁图标锁定长宽比再调大小。然后选中图片，选择`菜单->路径->临摹位图轮廓`，选择`亮度截断`，把阈值调得很高，我调到了0.990。这时整张图像在之前没有被删掉的部分就变黑了。然后点击`确定`，将更改应用到图片上，就得到剪影图了。

但是由于位图可能有些噪点，生成的剪影图上可能有一些不平滑的地方。这时可以选择左边工具栏里的`通过节点编辑路径`，把多余的路径节点删掉，并且改变剩下的点的方向，让边缘平滑。最后导出为图片就好了。
