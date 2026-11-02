# topbar 任务清单

> 进度事实源。完成一项勾一项；一个里程碑完成后，已完成的里程碑整段归档到 `tasks-archive.md`。

## M6 额度模块

- [x] `services/QuotaKimi.qml`：宽容解析（`usages` → `limits[]` → `usage`）、动态窗口、`reset_time` 倒计时、60s 刷新
- [x] `services/QuotaDeepSeek.qml`：`/user/balance`、5min 刷新、货币符号
- [x] `services/Secrets.qml`：`secrets.json` 权限校验（600/400）、env key 优先、key 增删自愈
- [x] `bar/QuotaRings.qml` + `bar/BalanceTag.qml`：Kimi 双窗口环 + 最早重置倒计时、DeepSeek 方块 + 数字
- [x] `core/Config.qml` / `Theme.qml` / `I18n.qml`：`secretsPath`、Kimi pink / DeepSeek sapphire、额度文案
- [x] 验证（离线样例）：current 结构 5h 42% + 7d 18%（4H/4D）、旧 `usage` 结构 7%/2%、仅 5h 单环、仅月窗口 M/C 55%/12% + 21D；401 / 连接失败 / 非 JSON / 空 `usages` / 无 key / secrets 644 均为灰环 + `--` 且无 QML 报错；secrets 600 正常读取，644 拒绝并 warn；现场删除 secrets 后 60s 内降级为 `--`，恢复后下一次轮询自动恢复；DeepSeek CNY ¥110.00、USD $12.34、`is_available=false` 警告色 + 「余额不足」；Latte + en 下 tooltip 为 `5-hour quota 42% · resets in 4H`
- [ ] 验证（真实 key）：提供 `KIMI_CODING_API_KEY` / `DEEPSEEK_API_KEY` 或 600 权限的 `secrets.json` 后，与 Kimi/DeepSeek 控制台核对百分比、重置时间与余额
