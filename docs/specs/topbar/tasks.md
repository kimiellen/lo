# topbar 任务清单

> 进度事实源。完成一项勾一项；一个里程碑完成后，已完成的里程碑整段归档到 `tasks-archive.md`。

## M6 额度模块

- [ ] `services/QuotaKimi.qml`：宽容解析（`usages` → `limits[]` → `usage`）、动态窗口、`reset_time` 倒计时、60s 刷新
- [ ] `services/QuotaDeepSeek.qml`：`/user/balance`、5min 刷新、货币符号
- [ ] `bar/QuotaRings.qml` + `bar/BalanceTag.qml`：Kimi 双窗口环 + 重置倒计时、DeepSeek 方块 + 数字
- [ ] 验证：真实 key 下与 Kimi/DeepSeek 控制台一致；删除 key 显示 `--` 不崩；模拟旧 `usage` 结构仍能解析
