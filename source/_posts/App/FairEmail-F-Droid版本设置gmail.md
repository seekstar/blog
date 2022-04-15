---
title: FairEmail设置gmail
date: 2022-04-12 19:33:29
tags:
---

google的OAuth只适用于google play和github版本的FairEmail，而F-Droid上的FairEmail的签名是用的另一个不被google信任的key，因此不能方便地适用OAuth来访问gmail。但是可以使用App Password来从google不信任的客户端访问gmail：<https://support.google.com/accounts/answer/185833>

App Password只适用于开启了两步验证的账户。进入google account security页面：<https://myaccount.google.com/security>，如果`2-Step Verification`为`off`，就点进去，然后按照提示一步一步设置即可。然后回到security页面：<https://myaccount.google.com/security>，就能看到多了一个`App passwords`了。点进去，按照提示设置即可。然后在FairMail的设置里选择`手动设置和更多账户选项`，把生成的应用密码当作账户密码用就好了。

有可能会报这个错：`SSL handshake timed out`，这个原因可能是梯子用的人太多，被google加入黑名单了，换个梯子可能就好了。

K-9 Mail也可以用这种方法设置gmail。

## 参考

<https://www.reddit.com/r/fossdroid/comments/fsghgx/how_to_use_gmail_accounts_in_fairemail/>
