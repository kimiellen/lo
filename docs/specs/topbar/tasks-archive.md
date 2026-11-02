# topbar 已完成里程碑归档

> 已完成里程碑的清单归档（勾选状态原样保留）。进度事实源见 `tasks.md`。

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

- [x] `services/SystemStats.qml`：`/proc/stat`（两次采样求 CPU）、`/proc/meminfo`（MemAvailable）、`df -P /`（30s）
- [x] `bar/SystemRings.qml`：CPU(blue)/内存(mauve)/磁盘(teal) 三环 + hover 明细 tooltip；不可用显示 `--`
- [x] `components/InfoRing.qml` + `components/Tooltip.qml`：环心字母 + PopupWindow 浮层（锚定顶栏下沿，居中于元素）；`UsageRing` 增加环心文字
- [x] `core/Config.qml`：首次构造同步读取配置，避免首帧按默认 Mocha 绘制环轨（后续主题切换本可正常重绘）
- [x] 验证：与 `top`/`free`/`df` 交叉核对（CPU 5% vs `top` 5.3%、内存 25% = (31937−23848)/31937、磁盘 2% = `df` 2%，GiB 换算 30.1/1750.5 与 `df` 一致）；10.2 分钟 soak 共 120 对采样，mean|Δ|=0.7pp、漂移斜率 +0.02pp/min（首尾同量级）；`df` 指向不存在路径时 D 环显示 `--`（验证后已还原）；Latte/Mocha 切换热重绘、中文 tooltip「CPU 占用 5%」正常

## M3 状态环

- [x] `services/Audio.qml`（Pipewire）、`services/Brightness.qml`（brightnessctl）、`services/Power.qml`（UPower）
- [x] `bar/StatusRings.qml`：音量/亮度/电池 + 缺失自动隐藏 + 滚轮/左键交互
- [x] 验证：与 `pactl`、`brightnessctl -m`、`upower -d` 对齐（音量 75%、亮度 60%、电池 97%）；左键静音后 `pactl` 为 `Mute: yes`、环心切 `×` 且变灰；滚轮音量 75→80→70、亮度 60→65→55（`pactl`/`brightnessctl -m` 回读一致）；缺失降级实测：无 PipeWire 隐藏音量环、`brightnessctl` 失败隐藏亮度环、无系统 D-Bus 隐藏电池环，均无 QML 报错；中英/Latte 切换与 hover 明细（`音量 75%`/`亮度 60%`/`电池 97% · 已充满`）正常

## M4 控制面板 + 网络/蓝牙 tab

- [x] `panels/Panel.qml`：全屏 overlay 容器（`PanelWindow`、Overlay 层/忽略独占区）、三 tab、`Esc`/点外关闭、打开时独占键盘焦点
- [x] `services/Wifi.qml`：iwctl 封装（adapter/station/get-networks/known-networks/scan/connect/disconnect/Powered）
- [x] `services/Link.qml`：`ip -br addr` 只读链路状态（网卡/UP-DOWN/地址，5s）
- [x] `services/BlueZ.qml`：`Quickshell.Bluetooth` 封装（已连/可用分组、限时扫描、电源开关）
- [x] `panels/tabs/NetworkTab.qml`：Wi-Fi 列表、连接、密码输入、链路只读状态
- [x] `panels/tabs/BluetoothTab.qml` + `panels/tabs/DeviceRow.qml`：已连/可用设备、开关、刷新
- [x] `components/ToggleSwitch.qml` + `components/EmptyState.qml`：面板开关与空状态
- [x] 验证：UI 断开路径现场生效（`iwctl` 随之为 disconnected，网由用户恢复，故未再真机重连）；连接链路用假 iwctl 验证命令为 `iwctl station wlan0 connect TestNet --passphrase s3cret`、状态回到 connected；Bluetooth tab 与 `bluetoothctl devices` 一致（EDIFIER S2000MKⅢ / MelGeek-C2 已连，电量 39% 与 `bluetoothctl info` 一致）；虚拟键盘注入密码框可输入（掩码显示）、`Esc` 关闭面板；点外关闭、列表滚轮滚动、Latte/en 渲染正常；假 iwctl 退出码 1 时显示「Wi-Fi 不可用」且无 QML 报错，链路区仍正常

## M5 代理 tab + 状态图标

- [x] `services/Proxy.qml`：mihomo `/configs`、`/proxies`、`secret` 解析、`PATCH /configs` 切 mode
- [x] `bar/StatusIcons.qml`：代理/网络/蓝牙三枚图标 + 点击开面板 + 异常变灰
- [x] `panels/tabs/ProxyTab.qml`：规则/全局/直连 + 当前节点 + TUN 状态
- [x] 规格修正：mihomo 1.19.33 的 `PUT /configs` 返回 204 但不生效，改用 `PATCH`（spec §5.3 同步）
- [x] 验证：UI 点「直连」后 `curl /configs` 回读 `mode=direct`，再点「规则」回读 `mode=rule`；面板「当前节点 香港010 / 策略组 自动选择」与 `/proxies` 的 `自动选择.now` 一致，TUN「已开启」与 `tun.enable=true` 一致；用 127.0.0.1:9099 空端口模拟控制器停机（未停 mihomo，避免中断网络）→ 图标变灰、面板「mihomo 不可用 / external-controller 无响应」、日志仅 1 条 warn 且无 QML 报错；仅给 controller 不给 secret → 401 降级为「secret 缺失或错误」；mihomo 配置文件缺失时回退 `config.json` 的 `mihomoController`/`mihomoSecret` 并正常读出；中文/Mocha 与英文/Latte 下三图标点击分别打开代理/网络/蓝牙 tab，hover 明细正常

## M6 额度模块

- [x] `services/QuotaKimi.qml`：宽容解析（`usages` → `limits[]` → `usage`）、动态窗口、`reset_time` 倒计时、60s 刷新
- [x] `services/QuotaDeepSeek.qml`：`/user/balance`、5min 刷新、货币符号
- [x] `services/Secrets.qml`：`secrets.json` 权限校验（600/400）、env key 优先、key 增删自愈
- [x] `bar/QuotaRings.qml` + `bar/BalanceTag.qml`：Kimi 双窗口环 + 最早重置倒计时、DeepSeek 方块 + 数字
- [x] `core/Config.qml` / `Theme.qml` / `I18n.qml`：`secretsPath`、Kimi pink / DeepSeek sapphire、额度文案
- [x] 验证（离线样例）：current 结构 5h 42% + 7d 18%（4H/4D）、旧 `usage` 结构 7%/2%、仅 5h 单环、仅月窗口 M/C 55%/12% + 21D；401 / 连接失败 / 非 JSON / 空 `usages` / 无 key / secrets 644 均为灰环 + `--` 且无 QML 报错；secrets 600 正常读取，644 拒绝并 warn；现场删除 secrets 后 60s 内降级为 `--`，恢复后下一次轮询自动恢复；DeepSeek CNY ¥110.00、USD $12.34、`is_available=false` 警告色 + 「余额不足」；Latte + en 下 tooltip 为 `5-hour quota 42% · resets in 4H`
- [x] 验证（真实 key）：secrets.json 600 下真实接口返回 5h `used_ratio=0`（02:26Z 重置）、7d `0.8866`（14:26Z 重置）、DeepSeek `¥26.75`/`is_available=true`；UI 显示 5h 0% · 2H、7d 89% · 12H、¥26.75，与原始 JSON 一致；关闭旧 Quickshell 后 vbc-Io 以常驻实例接管顶栏

## M7 卡片化样式与间隙对齐

- [x] `docs/specs/topbar/spec.md`：§2/§3/§4/§7 同步新的布局与视觉规范（用户确认后先改文档）
- [x] `services/Hypr.qml`：`hyprctl getoption general:gaps_out -j` 读取 css（上右下左，回退 10），30s 复查以跟随 `hyprctl reload`
- [x] `core/Metrics.qml`：卡片/环/字号尺寸 token；`core/Theme.qml` 加毛玻璃底色（base 70%）与 1px text 12% 描边；`Config.barHeight` 改为卡片高（默认 44）
- [x] `components/GlassCard.qml`：半透明圆角卡片，宽度随内容组件隐式尺寸
- [x] `bar/Bar.qml`：三区 7 张卡片；窗口高 = gap + 卡片高，`exclusiveZone` 同值且卡片贴底；单一 `BackgroundEffect`（`Region` 按卡片圆角）负责模糊
- [x] bar item 放大：环 24/3、工作区槽位 26/内环 20、字号 13（时钟/金额）与 11（倒计时/环心）、状态图标 22/17
- [x] `panels/Panel.qml`：面板 y = gap + 卡片高 + gap，不与卡片重叠
- [x] 验证：热重载无 QML 报错；`hyprctl layers` bar 为 1600×54；`hyprctl clients` 窗口 y=66（54 + gaps_out 10 + 边框 2），即卡片底到窗口顶只有一个 gap；截图量得卡片左边距 10、卡片间隙 10、时钟卡中心 1279/1280；Mocha/Latte 双主题截图正常；`WAYLAND_DEBUG=1` 探针确认出现 `ext_background_effect_manager_v1.get_background_effect` 与 3 次 `set_blur_region`，圆角模糊在 Hyprland 上生效（探针已删除）
