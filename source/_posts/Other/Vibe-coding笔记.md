---
title: Vibe coding笔记
date: 2026-06-09 23:19:34
tags:
---

## zellij

一般agent没有detach之后后台运行的功能。可以在zellij session里跑agent，这样可以随时detach，让agent在后台跑。

安装：

```shell
# nixpkgs
nix-env -iA nixpkgs.zellij
```

detach: `ctrl+o d`

```shell
zellij help
# list-sessions
zellij ls
# 新建一个名字随机的session并且attach
zellij
# 新建指定名字的session
zellij -s session名字
# attach
zellij a
# attach到指定session
zellij a session名字
# delete-all-sessions: 删除所有EXITED session
zellij da
```

## opencode

比较知名的开源agent。大部分模型应该都支持。

安装：<https://opencode.ai/download>

```shell
npm i -g opencode-ai
```

关闭一个session：`ctrl+c`

```shell
# 创建并进入一个session
opencode
opencode session list
# attach到session
opencode -s <sessionID>
# 删除session
opencode session delete <sessionID>
```

如果想让AI自动读某个自定义AGENTS.md，可以在`~/.config/opencode/opencode.jsonc`里加一行：

```json
  "instructions": ["~/path/to/your/AGENTS.md"]
```

存在的问题：

- CPU占用很高。

- 似乎没有原生支持在后台运行长时间任务。

## Codex

可以在后台运行长时任务并且周期性监测。

感觉对第三方的模型提供商的支持不太好。最好还是买一个Chatgpt Plus订阅。

官方文档：<https://developers.openai.com/codex/cli>

```shell
# 安装。如果已经是最新版也会重新安装
npm install -g @openai/codex
# 升级
npm update -g @openai/codex
```

如果是买的Chatgpt Plus订阅，好像得用登录的方式。一般在服务器上用的话得选device code的方式。如果用API key的话会提示没有额度。

```shell
# 列出以前的session，选一个resume
codex resume
# 直接resume到上一个session
codex resume --last
```

`/permissions`: 默认是`Ask for approval`，很烦。建议设置成`Approve for me`。

`/status`: 查看剩余额度。

会自动读取`~/.codex/AGENTS.md`。

存在的问题：

- 不能撤回之前的消息

## 失败的尝试

### Kimi code

好处是可以立刻使用Kimi最新发布的模型。体验也比较现代。但好像不能设置允许访问的目录，要么忍受及其繁琐的审批，要么就`/auto`全自动。

官网：<https://www.kimi.com/code>

安装：

```shell
curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash
```

会自动读取`~/.kimi-code/AGENTS.md`

存在的问题：

- 不能删除session：<https://github.com/MoonshotAI/kimi-cli/issues/1783>

目前（0.14.2）bug好像比较多，时不时会报错然后goal就停了，需要手动`/goal resume`。

Update: 遇到这个报错，怎么都resume不了，弃坑了。

```text
   Error: [provider.api_error] 400 Invalid request: an assistant message with 'tool_calls' must be
 followed by tool messages responding to each 'tool_call_id'. The following tool_call_ids did not
 have response messages: TaskOutput:96
```

会话导出为`.md`，可以让其他agent看了之后继续工作：`/export-md`

卸载：`rm -r ~/.kimi-code`

### Google Antigravity

好像不能设置代理。
