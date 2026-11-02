# vbc-Io 顶栏（topbar）— 规格说明

> 本文件是此 feature 的事实源。方向性变更走 spec-change 协议：先改本文件，再改代码。

## 1. 目标

在 Hyprland 上提供一个常驻顶栏（Quickshell 单进程），用统一的「环形用量图标」表达系统状态，
并集成个人工作流相关的三块数据：系统资源、AI 订阅额度（Kimi Code / DeepSeek）、网络与代理状态。

成功标准：

- 冷启动到可用 < 1s，日常使用中无需重启 Quickshell 进程。
- 主题（Catppuccin Mocha/Latte）与语言（中文/英文）切换即时生效并持久化。
- 关键数值（CPU/内存/电池/额度）与实际系统一致，误差可解释（采样间隔内）。
- 外部依赖（Kimi 接口、mihomo、iwd、蓝牙）任意一个不可用时，顶栏其余部分正常工作。

## 2. 运行环境（实测）

| 项 | 值 |
| --- | --- |
| 合成器 | Hyprland 0.57.0（0.56+ dispatch 改为 Lua API） |
| Quickshell | 0.3.2（Arch 包），Qt 6.12 |
| 显示 | 单屏 DP-2 3840×2160 @1.5，顶栏独占 40px |
| 网络 | iwd 1.104.4（Wi-Fi）、systemd-networkd（链路/IP）、systemd-resolved→mihomo DNS、mihomo 1.19.33 TUN（策略路由表 2022）；**不安装 NetworkManager** |
| 代理 | mihomo external-controller `127.0.0.1:9090`，需 secret（`/etc/mihomo/config.yaml` 可读） |
| 电源 | BAT0 + ADP0，背光 `nvidia_0`（brightnessctl 可用） |
| 音频 | PipeWire（pactl 可用） |
| 蓝牙 | bluez + bluetoothd 运行中 |

## 3. 布局

顶栏高 40px，三个区域：

- **左区**：从屏幕左边缘起等间距排列 → 工作区环（数量随 Hyprland 工作区动态）→ CPU/内存/磁盘三环 → Kimi 双窗口环 + 重置倒计时 → DeepSeek 余额。
- **中区**：日期 - 时间 - 星期，严格锚定屏幕水平中心（`anchors.centerIn`，不使用等分布局近似）。
- **右区**：从右边缘起等间距排列 → 音量/亮度/电池三环（设备缺失自动隐藏）→ 代理/网络/蓝牙三枚状态图标（点击展开控制面板）。

## 4. 视觉规范

统一「环形用量图标」：外环轨道 + 进度弧 + 中央字母/数字；进度弧用 `Shape + PathAngleArc` 绘制。

| 元素 | 值 |
| --- | --- |
| 顶栏高度 | 40 |
| 环外径 / 线宽 | 18 / 2.5（1.5 缩放下不出现半像素模糊） |
| 元素间距 | 8 |
| 字号 | 11（数字）、10（单位/倒计时） |
| 主字体 | `JetBrainsMono Nerd Font` → `JetBrains Mono` → `Noto Sans CJK SC` → `Alibaba PuHuiTi 3.0` → `sans-serif` |

配色全部取自 Catppuccin 官方色板（Mocha `#1e1e2e` 底 / Latte `#eff1f5` 底）：

| 用途 | Mocha 角色 | Latte 角色 |
| --- | --- | --- |
| CPU | blue | blue |
| 内存 | mauve | mauve |
| 磁盘 | teal | teal |
| 音量 | green | green |
| 亮度 | yellow | yellow |
| 电池 | peach（充电 green / <20 red） | 同左 |
| Kimi 额度环 | pink | pink |
| DeepSeek 余额 | sapphire | sapphire |
| 工作区 0 个窗口 | overlay0（空环） | overlay0 |
| 工作区 1–2 个窗口 | blue | blue |
| 工作区 3–4 个窗口 | yellow | yellow |
| 工作区 ≥5 个窗口 | red | red |
| 当前工作区 | 外圈用 text 色描边 | 同左 |
| 状态图标（代理/蓝牙正常） | lavender | lavender |
| 状态图标（Wi-Fi 已连接） | green | green |
| 状态图标（不可用/关闭） | overlay（灰） | overlay |

工作区环的进度 = `min(windows, 5) / 5`，颜色按上表分档（对应设计图「颜色分 4 档」）。

## 5. 数据源与刷新策略

| 模块 | 来源 | 刷新 | 不可用时 |
| --- | --- | --- | --- |
| 工作区 | `Quickshell.Hyprland`（`workspaces` + `lastIpcObject.windows`） | 事件驱动 | 隐藏 |
| CPU | `/proc/stat` 两次采样求差 | 1s | 显示 `--` |
| 内存 | `/proc/meminfo`（`MemAvailable`） | 2s | `--` |
| 磁盘 | `statvfs("/")` 或 `df -P /` | 30s | `--` |
| 音量 | `Quickshell.Services.Pipewire` | 事件 | 隐藏 |
| 亮度 | `brightnessctl -m` | 1s | 隐藏 |
| 电池 | `Quickshell.Services.UPower`（`displayDevice`） | 事件 | 隐藏 |
| Kimi 额度 | `GET https://api.kimi.com/coding/v1/usages` | 60s | 灰环 + `--` |
| DeepSeek 余额 | `GET https://api.deepseek.com/user/balance` | 5min | `--` |
| 代理 | mihomo `GET /configs`、`GET /proxies` | 5s | 灰图标 |
| Wi-Fi | `iwctl`（已验证普通用户可读写） | 10s + 面板内即时 | 图标离线 |
| 蓝牙 | `Quickshell.Bluetooth` | 事件 | 隐藏 |

HTTP 统一用 `curl` 子进程（已安装）：`--max-time 8` + 显式 header，解析失败只记日志不抛错。

### 5.1 Kimi 额度

- 接口未公开，已发生过一次结构变更（`usage` → `usages`），解析器必须宽容：优先读 `usages.{limit_5h,limit_7d,limit_month_total,limit_month_code}` 的 `used_ratio`/`reset_time`；`limits[].detail`（5h 窗口 `window.duration=300`）与顶层 `usage`（周额度）只补齐 `usages` 缺失的窗口，避免同一窗口重复画环。
- **窗口动态渲染**：解析器不硬编码窗口集合，顺序固定为 `5h → 7d → month_total → month_code → 未知窗口`；顶栏最多渲染前两个（“双窗口环”），只有一个窗口时只画一个环。月窗口是 5h/7d 缺失时的回退，不会被丢弃。
- 倒计时由 `reset_time` 计算，格式 `2H` / `1D` / `3D`；顶栏显示两个窗口中最早到期的重置，`hover` 明细分别给出各窗口的百分比与重置时间。
- 认证：环境变量 `KIMI_CODING_API_KEY` 优先，其次 `~/.config/vbc-io/secrets.json` 的 `kimi_api_key`（权限 600，亦接受更严格的 400；其他权限视为未配置并记一条 warn）。**不读取 `~/.dsh` 私有目录。**
- 无 key / 401 / 超时 / 解析失败：灰色 `--` 环，不抛错、不阻塞顶栏；恢复 key 后下一次轮询自动恢复。

### 5.2 DeepSeek 余额

- 官方接口，字段为字符串：`balance_infos[0].total_balance`（按 `currency` 显示 ¥/$），`is_available`。
- 只有金额没有分母，因此**不画进度环**：保持设计图的「圆角方块图标 + 数字」。
- 多币种时取 `balance_infos[0]`；`is_available=false` 时金额改用警告色，但仍显示数值。
- 认证：`DEEPSEEK_API_KEY` 环境变量或 `secrets.json` 的 `deepseek_api_key`（权限要求同 §5.1）；无 key / 401 / 超时 / 解析失败显示 `--`。

### 5.3 代理（mihomo）

- 读 `/etc/mihomo/config.yaml` 的 `external-controller` 与 `secret` 两行（正则解析），失败回退 `config.json` 手填值。
- 状态：`mode`（rule/global/direct）+ TUN 是否开启（`/configs` 的 `tun.enable`）+ 当前节点（`/proxies`）。
- 当前节点：global 模式跟随 `GLOBAL.now`；rule 模式取成员最多的策略组并递归解析到具体节点；direct 显示 `DIRECT`。
- 操作（V1）：切换 mode（`PATCH /configs` `{"mode": ...}`；实测 mihomo 1.19.33 对 `PUT` 返回 204 但不生效）；不重启、不修改 TUN。

### 5.4 网络（iwd + networkd）

- Wi-Fi：`iwctl station <dev> scan|get-networks|connect <ssid> [--passphrase]`、`known-networks list`、`adapter <dev> set-property Powered on|off`；输出解析集中在 `services/Wifi.qml` 一处。
- 链路状态：`networkctl list --no-pager` 或 `ip -br addr`，**只读**。
- 以太网开关 V1 不做（networkd 为声明式配置，运行时开关语义不清晰）。

## 6. 交互

| 元素 | 左键 | 滚轮 | 其他 |
| --- | --- | --- | --- |
| 工作区环 | 切换到该工作区（走 Hyprland Lua dispatch） | — | hover 显示窗口数 |
| 系统三环 | 打开控制面板 | — | hover 显示明细 |
| 音量环 | 静音切换 | 调节音量 | hover 显示百分比 |
| 亮度环 | — | 调节亮度 | hover 显示百分比 |
| 电池环 | — | — | hover 显示剩余时间/功率 |
| 状态图标 | 打开控制面板（对应 tab） | — | 异常时变灰（与 §5「不可用」一致） |
| 时钟 | — | — | hover 显示完整日期 |

控制面板：全屏 `PanelWindow` overlay（Overlay 层、忽略独占区）承载，面板实际锚定顶栏右下方；tab = 代理 / 网络 / 蓝牙；`Esc` 或点击外部关闭；打开时独占键盘焦点（网络 tab 密码输入需要），关闭后归还。

## 7. 主题与语言

- 主题：Mocha（默认）/ Latte，手动切换，持久化到 `~/.config/vbc-io/config.json`。
- 语言：`zh-CN`（默认）/ `en`，切换即时生效；所有可见文案走 `I18n` 单例，日期/星期格式在 `I18n` 内格式化。
  - zh：`11月1日 - 21:26 - 周一`
  - en：`1 Nov - 09:26 PM - Mon`
- 配置项：`theme`、`language`、`barHeight`、`mihomoConfigPath`、`mihomoController`/`mihomoSecret`（配置读取失败时回退）、`secretsPath`。

## 8. 代码结构

```
vbc-io/
├── shell.qml                # ShellRoot：每屏一个 Bar，控制面板宿主
├── core/                    # Theme / I18n / Config / Format
├── services/                # 所有外部数据与副作用（无 UI）
├── components/              # UsageRing、StatusIcon 等原子组件
├── bar/                     # Bar 三区布局与各 item
└── panels/                  # 控制面板与 tab
```

规则：UI 只做绑定与布局，所有轮询/HTTP/命令执行只出现在 `services/`；颜色取 `Theme`，文案取 `I18n`，禁止散落硬编码。

## 9. 非目标（V1）

通知中心、媒体控制/歌词、温度与 GPU、OBS 状态、输入法状态、bar 自动隐藏、多显示器差异化配置、主题按时间自动切换、mihomo TUN 开关。

## 10. 风险

| 风险 | 影响 | 缓解 |
| --- | --- | --- |
| Kimi 接口非公开、结构会变 | 额度模块失效 | 宽容解析 + 灰环降级 + 单测式样例数据校验 |
| API key 明文存放 | 泄露 | 仅读环境变量或 600 权限文件；不进仓库、不入日志 |
| iwctl 输出格式随版本变化 | Wi-Fi 列表异常 | 解析集中一处，失败显示「扫描不可用」 |
| Quickshell 0.3.2 与 Hyprland 0.57 的 dispatch 差异 | 点击工作区无效 | 统一走 Lua dispatch 包装（已验证写法） |
| 1.5 缩放下环边缘模糊 | 视觉廉价 | 尺寸取偶数、关闭平滑、必要时用 0.5 对齐 |
