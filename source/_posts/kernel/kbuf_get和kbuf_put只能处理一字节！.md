---
title: kbuf_get和kbuf_put只能处理一字节！
date: 2020-12-01 15:50:37
---

惊天巨坑！！！文档里信誓旦旦的说是element，结果合着就是byte呗。我看这东西是宏定义，以为会自动用sizeof(typeof(val))把字节数求出来，结果这个信息就这样被漏掉了。。。

要压入或者弹出多字节的元素，那只能用```kbuf_in```和```kbuf_out```了。
