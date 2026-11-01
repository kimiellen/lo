# topbar 任务清单

> 进度事实源。完成一项勾一项；一个里程碑完成后，已完成的里程碑整段归档到 `tasks-archive.md`。

## M1 骨架与视觉语言

- [x] 仓库初始化：`git init`、`.gitignore`、`AGENTS.md`、`spec.md`
- [x] `core/Theme.qml`：Catppuccin Mocha/Latte 双色板 + 语义角色（bg/text/subtext/overlay/accent 全套）
- [x] `core/I18n.qml`：中英文案字典 + 时钟/日期格式化（`11月1日 - 21:26 - 周一` / `1 Nov - 09:26 PM - Mon`）
- [x] `core/Config.qml`：`~/.config/vbc-io/config.json` 读写（theme/language/barHeight），支持 `VBCIO_CONFIG_DIR` 覆盖
- [x] `core/Format.qml`：百分比、倒计时、货币格式化
- [x] `components/UsageRing.qml`：`Shape + PathAngleArc` 圆环，参数 value/color/track/size/thickness
- [x] `services/Hypr.qml`：工作区列表 + 聚焦工作区 + Lua dispatch 包装
- [x] `bar/Bar.qml`：PanelWindow（top layer、独占 40px、三区布局，中区绝对居中）
- [x] `bar/Workspaces.qml`：动态工作区环（0/1–2/3–4/≥5 四档配色、当前工作区描边、左键切换）
- [x] `bar/Clock.qml`：`SystemClock` 每秒刷新 + 双语格式
- [x] `shell.qml`：`ShellRoot` + 每屏一个 Bar；`IpcHandler` 暴露 `theme toggle` / `language toggle`
- [x] 验证：`qs -c vbc-io` 启动无 QML 报错；时钟中心实测 x=1921/3840；`qs ipc call theme toggle` 后背景变为 `#eff1f5` 且 `config.json` 落盘；重启后保持 Latte/en；`hl.get_active_monitor():set_workspace(3)` 回读 `hyprctl activeworkspace` = 3

## M2 系统三环

- [ ] `services/SystemStats.qml`：`/proc/stat`（两次采样求 CPU）、`/proc/meminfo`（MemAvailable）、`df -P /`（30s）
- [ ] `bar/SystemRings.qml`：CPU(blue)/内存(mauve)/磁盘(teal) 三环 + hover 明细 tooltip
- [ ] 验证：与 `top`/`free`/`df` 交叉核对；连续 10 分钟 CPU 数值不漂移；`df` 不可用时显示 `--`

## M3 状态环

- [ ] `services/Audio.qml`（Pipewire）、`services/Brightness.qml`（brightnessctl）、`services/Power.qml`（UPower）
- [ ] `bar/StatusRings.qml`：音量/亮度/电池 + 缺失自动隐藏 + 滚轮/左键交互
- [ ] 验证：与 `pactl`、`brightnessctl -m`、`upower -d` 对齐；静音图标切换；滚轮生效

## M4 控制面板 + 网络/蓝牙 tab

- [ ] `panels/Panel.qml`：PopupWindow 容器、三 tab、Esc/点外关闭
- [ ] `services/Wifi.qml`：iwctl 封装（scan/get-networks/connect/known-networks/Powered）
- [ ] `panels/tabs/NetworkTab.qml`：Wi-Fi 列表、连接、密码输入、链路只读状态
- [ ] `panels/tabs/BluetoothTab.qml`：已连/可用设备、开关、刷新
- [ ] 验证：真实连接一个已知 Wi-Fi；`bluetoothctl devices` 交叉核对；密码框可输入、Esc 关闭

## M5 代理 tab + 状态图标

- [ ] `services/Proxy.qml`：mihomo `/configs`、`/proxies`、`secret` 解析、`PUT /configs` 切 mode
- [ ] `bar/StatusIcons.qml`：代理/网络/蓝牙三枚图标 + 点击开面板 + 异常变灰
- [ ] `panels/tabs/ProxyTab.qml`：规则/全局/直连 + 当前节点 + TUN 状态
- [ ] 验证：切 mode 后 `curl /configs` 一致；停 mihomo 后图标变灰不报错；secret 缺失时降级

## M6 额度模块

- [ ] `services/QuotaKimi.qml`：宽容解析（`usages` → `limits[]` → `usage`）、动态窗口、`reset_time` 倒计时、60s 刷新
- [ ] `services/QuotaDeepSeek.qml`：`/user/balance`、5min 刷新、货币符号
- [ ] `bar/QuotaRings.qml` + `bar/BalanceTag.qml`：Kimi 双窗口环 + 重置倒计时、DeepSeek 方块 + 数字
- [ ] 验证：真实 key 下与 Kimi/DeepSeek 控制台一致；删除 key 显示 `--` 不崩；模拟旧 `usage` 结构仍能解析
