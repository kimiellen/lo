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

