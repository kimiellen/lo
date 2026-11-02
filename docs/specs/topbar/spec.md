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
| 显示 | 单屏 eDP-1 2560×1600 @1.6，顶栏独占 52px（上下边距 12 + 卡片 38 + 底部补偿 2） |
| 网络 | iwd 1.104.4（Wi-Fi）、systemd-networkd（链路/IP）、systemd-resolved→mihomo DNS、mihomo 1.19.33 TUN（策略路由表 2022）；**不安装 NetworkManager** |
| 代理 | mihomo external-controller `127.0.0.1:9090`，需 secret（`/etc/mihomo/config.yaml` 可读） |
| 电源 | BAT0 + ADP0，背光 `nvidia_0`（brightnessctl 可用） |
| 音频 | PipeWire（pactl 可用） |
| 蓝牙 | bluez + bluetoothd 运行中 |

## 3. 布局

顶栏是一排不透明卡片，分三个区域。顶栏四周留白左右 15、上下 12（`Metrics.outerMarginX/Y`），卡片之间 8（`Metrics.cardGap`）：

- **纵向**：窗口高 = 上下边距 + 卡片高 + 底部补偿（当前 12 + 38 + 2 = 52），独占区 = 窗口高。
  屏幕顶 → 卡片顶 = 12；Hyprland 在独占区边界会再补一次 `gaps_out`，因此卡片底到首个窗口顶
  要多留 `max(0, 上下边距 − gaps_out)` 的透明条，补偿后卡片底 → 窗口顶正好是 12（不再叠出双间隙）。
- **横向**：卡片距屏幕左/右各 15，卡片之间 8。
- **左区**：工作区环（数量随 Hyprland 工作区动态）、CPU/内存/磁盘三环、Kimi 矢量标 + 7 天/5 小时额度环（各自跟自己的重置倒计时）、DeepSeek 余额，各一张卡片。
- **中区**：日期 - 时间 - 星期卡片，卡片中心严格锚定屏幕水平中心（`anchors.horizontalCenter`，不使用等分布局近似）。
- **右区**：一张状态卡片，从左到右依次为主题切换按钮、麦克风静音、音量图标 + 音量环、亮度图标 + 亮度环、
  电池图标 + 电池环（设备缺失自动隐藏）；代理/网络/蓝牙三枚状态图标另占一张卡片（点击展开控制面板）。

## 4. 视觉规范

统一「环形用量图标」：外环轨道 + 进度弧 + 中央字母/数字；进度弧用 `Shape + PathAngleArc` 绘制，
`preferredRendererType: Shape.CurveRenderer`（抗锯齿内置，不依赖窗口多重采样）。

状态卡图标为 26×26 自绘矢量（与环同高；20×20 绘制视框等比放大，不依赖字体 codepoint）：麦克风、喇叭（按音量画 1–3 道声波，静音为斜线）、
太阳、电池（外框 + 按电量连续填充，充电时显示闪电）。

状态图标卡：网络/蓝牙沿用 Nerd Font 字形（盒 26、字形 24），代理改为 24×24 自绘矢量派生图标：
共同的「地球」底形 + 右下角模式徽标——规则=列表线、全局=小圆环、直连=斜向箭头；徽标先用卡片
底色切口与底形分离。随 `Proxy.mode` 切换，未知模式或不可用时只画灰地球（无徽标）。

| 元素 | 值 |
| --- | --- |
| 顶栏窗口高度 | 上下边距 + 卡片高 + 底部补偿，三项各自按 1/DPR 吸附到整设备像素（1.6 缩放下 11.875 + 38.125 + 1.875 = 51.875 = 83 设备像素，buffer 落在整行不再被合成器重采样） |
| 卡片 | 高 38（默认，`barHeight`）、圆角 18、横向内边距 10；底色 base 不透明 + 1px text 12% 描边（1px 与卡片宽度同按 1/DPR 吸附） |
| 卡片间隙 / 屏边距 | 8 / 左右 15、上下 12（间隙同按 1/DPR 吸附，卡片左边逐项落在像素网格上） |
| 环外径 / 线宽 | 26 / 3（按设备像素吸附：1.6 缩放下实际 26.25 / 3.125） |
| 工作区槽位 / 工作区环 | 26 / 20 |
| 字号 | 15（全部文字）；状态卡环心固定 15、不按字符数缩放：0–99 显示整数百分比，100 显示 `F` |
| 状态图标盒 / 字形 | 26 / 24（代理/网络/蓝牙；代理为 24×24 矢量派生图标） |
| 状态卡图标 | 26×26 自绘矢量（与环同高），颜色跟随对应环 |
| 主题按钮 | 高 24、圆角 6、1px 描边、文字 15；宽度随本地化文案 |
| 控制面板 | 宽 400、圆角 12、内边距 12、tab 高 30；最大高 640（随屏高收缩） |
| 面板字号 | 数值/标题 13、正文/标签 12、次要信息 11；tab 标签 12 |
| 代理模式按钮 | 高 30、圆角 8，图标 16 + 文字 13 居中并排 |
| 状态卡模块间距 / 图标与环 | 10 / 4 |
| 品牌矢量标宽 | 24（鲸标、K 标） |
| 主字体 | `JetBrainsMono Nerd Font` → `JetBrains Mono` → `Noto Sans CJK SC` → `Alibaba PuHuiTi 3.0` → `sans-serif` |

配色全部取自 Catppuccin 官方色板（Mocha `#1e1e2e` 底 / Latte `#eff1f5` 底）：

| 用途 | Mocha 角色 | Latte 角色 |
| --- | --- | --- |
| CPU | blue | blue |
| 内存 | mauve | mauve |
| 磁盘 | teal | teal |
| 音量 | green | green |
| 亮度 | yellow | yellow |
| 电池（环与图标） | 分档状态色：<20% red、20–60% yellow、≥60% green；充电 green | 同左 |
| 状态卡图标（麦克风/喇叭/太阳/电池） | 跟随对应环颜色；麦克风静音用 overlay | 同左 |
| Kimi 7 天额度环 | sapphire | sapphire |
| Kimi 5 小时额度环 | flamingo | flamingo |
| Kimi 其他窗口环（月度/代码，回退） | pink | pink |
| Kimi 矢量标 | 官方三色：黑底 `#000000` + 白 K `#FFFFFF` + 蓝点 `#1683FF` | 同左 |
| DeepSeek 矢量标 | 官方品牌色 `#4d6bfe`（非 Catppuccin 角色）；不可用 overlay、余额不足 warning | 同左 |
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
| 麦克风 | `Quickshell.Services.Pipewire`（`defaultAudioSource`） | 事件 | 隐藏 |
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
- **窗口动态渲染**：解析器不硬编码窗口集合，顶栏取窗顺序固定为 `7d → 5h → month_total → month_code → 未知窗口`；最多渲染前两个（“双窗口环”），只有一个窗口时只画一个环。7 天与 5 小时固定配色（sapphire / flamingo），月/代码窗口是缺失时的回退，用 pink，不会被丢弃。
- 倒计时由 `reset_time` 计算：7 天窗口按天显示（`1D` / `3D`，不足一天也算 `1D`），5 小时窗口按小时显示（`3H`）；每个环后面紧跟自己的重置倒计时标签（颜色同该环），`hover` 明细给出该窗口的百分比与重置时间。
- 认证：环境变量 `KIMI_CODING_API_KEY` 优先，其次 `~/.config/vbc-io/secrets.json` 的 `kimi_api_key`（权限 600，亦接受更严格的 400；其他权限视为未配置并记一条 warn）。**不读取 `~/.dsh` 私有目录。**
- 无 key / 401 / 超时 / 解析失败：灰色 `--` 环，不抛错、不阻塞顶栏；恢复 key 后下一次轮询自动恢复。

### 5.2 DeepSeek 余额

- 官方接口，字段为字符串：`balance_infos[0].total_balance`（按 `currency` 显示 ¥/$），`is_available`。
- 只有金额没有分母，因此**不画进度环**：DeepSeek 官方矢量标（`components/DeepSeekMark.qml`，内嵌官方 path，viewBox 0 0 1391 1024，`PathSvg` + `CurveRenderer` 绘制）+ 金额数字。
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
| 音量模块（图标 + 环） | 静音切换 | 调节音量 | hover 显示百分比；图标按音量画 1–3 道声波 |
| 亮度模块（图标 + 环） | — | 调节亮度 | hover 显示百分比 |
| 电池模块（图标 + 环） | — | — | hover 显示剩余时间/功率；图标按电量填充、按分档着色 |
| 主题按钮 | dark → light → auto 循环切换 | — | hover 显示当前模式 |
| 麦克风 | 切换默认输入源静音 | — | 静音时图标加斜线并变灰，hover 显示状态 |
| 状态图标 | 打开控制面板（对应 tab） | — | 异常时变灰（与 §5「不可用」一致）；代理图标随 `Proxy.mode` 换派生图标 |
| 时钟 | — | — | hover 显示完整日期 |

控制面板：全屏 `PanelWindow` overlay（Overlay 层、忽略独占区）承载，面板实际锚定顶栏右下方；宽 400，
高随内容在 140–640 之间收缩；tab = 代理 / 网络 / 蓝牙；`Esc` 或点击外部关闭；打开时独占键盘焦点
（网络 tab 密码输入需要），关闭后归还。代理 tab 的模式按钮高 30，图标 + 文字并排显示三种模式。

## 7. 主题与语言

- 主题三态：`dark`（Mocha，默认）/ `light`（Latte）/ `auto`。auto 按本机时间决定：06:00–18:00 用 light，
  其余用 dark，跨过边界后自动生效；持久化到 `~/.config/vbc-io/config.json` 的 `theme`
  （存 `mocha`/`latte`/`auto`，兼容旧值）。主题按钮与 IPC `theme set` 均支持三态。
- 语言：`zh-CN`（默认）/ `en`，切换即时生效；所有可见文案走 `I18n` 单例，日期/星期格式在 `I18n` 内格式化。
  - zh：`11月1日 - 21:26 - 周一`
  - en：`1 Nov - 09:26 PM - Mon`
- 配置项：`theme`、`language`、`barHeight`（卡片高，28–64，默认 38；顶栏总高 = 上下边距 + barHeight + 底部补偿）、`mihomoConfigPath`、`mihomoController`/`mihomoSecret`（配置读取失败时回退）、`secretsPath`。

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

通知中心、媒体控制/歌词、温度与 GPU、OBS 状态、输入法状态、bar 自动隐藏、多显示器差异化配置、mihomo TUN 开关。

## 10. 风险

| 风险 | 影响 | 缓解 |
| --- | --- | --- |
| Kimi 接口非公开、结构会变 | 额度模块失效 | 宽容解析 + 灰环降级 + 单测式样例数据校验 |
| API key 明文存放 | 泄露 | 仅读环境变量或 600 权限文件；不进仓库、不入日志 |
| iwctl 输出格式随版本变化 | Wi-Fi 列表异常 | 解析集中一处，失败显示「扫描不可用」 |
| Quickshell 0.3.2 与 Hyprland 0.57 的 dispatch 差异 | 点击工作区无效 | 统一走 Lua dispatch 包装（已验证写法） |
| 分段缩放下环边缘锯齿、1px 描边发虚 | 视觉廉价 | 环走 `Shape.CurveRenderer`（不依赖窗口多重采样）；环径取偶数设备像素、线宽与卡片高按 1/DPR 吸附整设备像素（`Metrics.snap` / `snapEven`） |
| auto 主题只跟随本机时钟 | 与用户作息/系统主题不一致时观感不符 | 固定 06:00–18:00；手动切 dark/light 立即覆盖 |
