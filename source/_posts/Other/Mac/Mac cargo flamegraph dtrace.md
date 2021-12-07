---
title: Mac cargo flamegraph dtrace
date: 2021-07-13 18:37:16
---

```
dtrace: system integrity protection is on, some features will not be available
dtrace: failed to initialize dtrace: DTrace requires additional privileges
```
其实不需要把SIP关掉，只需要用sudo运行```cargo flamegraph```即可。
