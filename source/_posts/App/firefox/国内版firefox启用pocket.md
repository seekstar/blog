---
title: 国内版firefox启用pocket
date: 2021-09-23 11:36:07
---

之前我是国际版的firefox。有一次升级时不知道怎么就变成国内版了，pocket图标也没了。这应该因为国内版firefox默认禁用了pocket，解决方法是在地址栏输入`about:config`，然后搜索`pocket`，找到`extensions.pocket.enabled`，双击后面的值，把`false`改成`true`，然后pocket的图标就回来了。

参考文献：

<https://support.mozilla.org/zh-CN/kb/%E4%BD%BF%E7%94%A8%20Pocket%20for%20Firefox%20%E4%BF%9D%E5%AD%98%E7%BD%91%E9%A1%B5%E4%BB%A5%E4%BE%9B%E7%A8%8D%E5%90%8E%E6%9F%A5%E7%9C%8B>
<https://support.mozilla.org/zh-CN/kb/%E7%A6%81%E7%94%A8%20Pocket-for-Firefox>
