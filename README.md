# Shadowrocket-Rules

我自用的 [Shadowrocket](https://apps.apple.com/app/id932747118) 分流规则，公开托管方便直接订阅。

## 用法

在 Shadowrocket App 里「配置」→ 右上角 `+` → 类型选 URL，填：

```
https://raw.githubusercontent.com/StarryGuli/Shadowrocket-Rules/refs/heads/main/sr_banlist_ad_jd.conf
```

App 会按 `update-url` 定期自动拉取最新版本。

## 内容结构

`sr_banlist_ad_jd.conf` 由两部分拼接而成：

1. **自定义规则区**（文件靠前部分，`[General]` / `[Rule]` 开头一段）——按 App 手动整理的分流规则，例如网易云音乐、Bilibili 走 DIRECT，Claude/OpenAI/Notion/Bumble/Tinder/MakerWorld/MiniMax/LongBridge 等走 PROXY。新增/修改某个 App 的分流规则，改这一段。
2. **广告拦截清单**（文件后半部分，REJECT 规则为主）——合并自社区维护的 [Johnshall/Shadowrocket-ADBlock-Rules-Forever](https://github.com/Johnshall/Shadowrocket-ADBlock-Rules-Forever)，体量较大，一般不需要手动改，除非要更新到上游最新版。

## 维护说明

- 改分流规则：直接在 `[Rule]` 段对应分类下增删 `DOMAIN-SUFFIX,xxx,PROXY|DIRECT` 行，改完记得同步更新文件头的 `Last Updated`。
- `[MITM]` 段默认 `enable = false`，**不要**在这里提交任何证书私钥（`ca-p12`）或密码——本仓库是公开的，提交私钥等于把它公开给所有人。MITM 证书只保留在本机 Shadowrocket App 内，不进 git。
- 规则较多，提交前建议跑一遍去重（同一条 `DOMAIN-SUFFIX,xxx,ACTION` 不应重复出现）。

## License

见 [LICENSE](LICENSE)。
