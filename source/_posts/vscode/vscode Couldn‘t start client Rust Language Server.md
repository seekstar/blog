---
title: vscode Couldn‘t start client Rust Language Server
date: 2021-05-14 11:51:07
---

首先要安装rustup: <https://rustup.rs/>

Mac上可能会出现已经安装了rustup，但是vscode仍然报这个错的现象，这好像是vscode rust插件的问题。相关issue仍然是open的状态：
<https://github.com/rust-lang/vscode-rust/issues/622>
<https://github.com/rust-lang/vscode-rust/issues/700>
解决方案是在settings.json里加入
```json
"rust-client.rustupPath": "$HOME/.cargo/bin/rustup",
```
然后重启vscode就好了。

参考文献：
<https://stackoverflow.com/questions/60816886/how-do-i-solve-couldnt-start-client-rust-language-server-with-the-rust-vs-cod>
