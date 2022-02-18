---
title: "bad decrypt 140291642319936:error:06065064:digital envelope routines:EVP_DecryptFinal_ex:bad decrypt"
date: 2020-08-22 17:15:51
tags:
---

密码输错了。或者是解密选项与加密选项不对应。比如加密时没有使用`-pbkdf2`，但是解密时使用了，就会报这个错。
