---
title: >-
  npm does not support Node.js v10.21.0. You should probably upgrade to a newer
  version of node
date: 2021-12-30 20:42:57
tags:
---

```shell
npm --version
```

```
npm does not support Node.js v10.21.0
You should probably upgrade to a newer version of node as we
can't make any promises that npm will work with this version.
You can find the latest version at https://nodejs.org/
/usr/local/lib/node_modules/npm/lib/npm.js:32
  #unloaded = false
  ^

SyntaxError: Invalid or unexpected token
    at Module._compile (internal/modules/cjs/loader.js:723:23)
    at Object.Module._extensions..js (internal/modules/cjs/loader.js:789:10)
    at Module.load (internal/modules/cjs/loader.js:653:32)
    at tryModuleLoad (internal/modules/cjs/loader.js:593:12)
    at Function.Module._load (internal/modules/cjs/loader.js:585:3)
    at Module.require (internal/modules/cjs/loader.js:692:17)
    at require (internal/modules/cjs/helpers.js:25:18)
    at module.exports (/usr/local/lib/node_modules/npm/lib/cli.js:22:15)
    at Object.<anonymous> (/usr/local/lib/node_modules/npm/bin/npm-cli.js:2:25)
    at Module._compile (internal/modules/cjs/loader.js:778:30)
```

这通常是因为先通过

```shell
sudo npm install npm@latest -g
```

升级了npm，但是没有升级node导致的。这时用包管理器安装的老版本npm升级一下node即可：

```shell
sudo /bin/npm install -g n
sudo n stable
PATH="$PATH"
```

然后就正常了

```shell
npm --version
```

```
8.3.0
```
