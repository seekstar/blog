---
title: websocketpp读取二进制
date: 2020-06-07 16:50:28
tags:
---

直接msg->get_payload().data()就好了。
std::string里可以装'\0'，用data()就可以访问。

参考：
<https://github.com/zaphoyd/websocketpp/issues/412>
