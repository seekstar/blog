---
title: >-
  fatal: 无法访问 'https://aur.archlinux.org/debtap.git/'：OpenSSL SSL_connect:
  SSL_ERROR_SYSCALL in connection to aur.archlinux.org:443
date: 2022-04-28 15:12:17
tags:
---

我把`~/.gitconfig`里的

```text
[http]
        proxy = socks5://127.0.0.1:8235
```

改成

```text
[http]
        proxy = http://127.0.0.1:8234
```

就好了。但是我在另一台机器上用别人的`socks5`代理作为git的http代理就没问题。难道是因为我用的clash？
