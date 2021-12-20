---
title: vue-cli-service Permission denied
date: 2019-11-25 18:01:10
---

环境：ubuntu 18.04 LTS

运行npm run dev，出现如下错误：
```bash
searchstar@searchstar-YangTianA8000f-11:~/git/projects/pingshanxyz$ sudo npm run dev
[sudo] password for searchstar: 

> vue-element-admin@4.2.1 dev /home/searchstar/git/projects/pingshanxyz
> vue-cli-service serve

sh: 1: vue-cli-service: Permission denied
npm ERR! code ELIFECYCLE
npm ERR! errno 126
npm ERR! vue-element-admin@4.2.1 dev: `vue-cli-service serve`
npm ERR! Exit status 126
npm ERR! 
npm ERR! Failed at the vue-element-admin@4.2.1 dev script.
npm ERR! This is probably not a problem with npm. There is likely additional logging output above.

npm ERR! A complete log of this run can be found in:
npm ERR!     /home/searchstar/.npm/_logs/2019-11-25T09_47_28_418Z-debug.log
```

npm install一下，又出现如下错误：

```bash
searchstar@searchstar-YangTianA8000f-11:~/git/projects/pingshanxyz$ npm install
npm WARN deprecated fsevents@1.2.9: One of your dependencies needs to upgrade to fsevents v2: 1) Proper nodejs v10+ support 2) No more fetching binaries from AWS, smaller package size
npm notice created a lockfile as package-lock.json. You should commit this file.
npm WARN optional SKIPPING OPTIONAL DEPENDENCY: fsevents@1.2.9 (node_modules/fsevents):
npm WARN notsup SKIPPING OPTIONAL DEPENDENCY: Unsupported platform for fsevents@1.2.9: wanted {"os":"darwin","arch":"any"} (current: {"os":"linux","arch":"x64"})

up to date in 7.159s

┌──────────────────────────────────────────────────────────────┐
│                   npm update check failed                    │
│             Try running with sudo or get access              │
│             to the local update config store via             │
│ sudo chown -R $USER:$(id -gn $USER) /home/searchstar/.config │
└──────────────────────────────────────────────────────────────┘
```

按照提示，输入
```bash
sudo chown -R $USER:$(id -gn $USER) /home/searchstar/.config
```

然后把node_modules丢掉
```bash
mv node_modules/ ..
```
再跑一次
```bash
npm install
npm run dev
```
就成功跑起来了。
