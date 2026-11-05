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
| 显示 | 多屏自适应（每屏一个 Bar，几何按各屏 DPR 吸附）：eDP-1 2560×1600 @1.6 与 DP-2 3840×2160 @1.5 实测；顶栏外边距随 `gaps_out` 伸缩，见 §3 |
| 网络 | iwd 1.104.4（Wi-Fi）、systemd-networkd（链路/IP）、systemd-resolved→mihomo DNS、mihomo 1.19.33 TUN（策略路由表 2022）；**不安装 NetworkManager** |
| 代理 | mihomo external-controller `127.0.0.1:9090`，需 secret（`/etc/mihomo/config.yaml` 可读） |
| 电源 | BAT0 + ADP0，背光 `nvidia_0`（brightnessctl 可用） |
| 音频 | PipeWire（pactl 可用） |
| 蓝牙 | bluez + bluetoothd 运行中 |

## 3. 布局

顶栏是一排毛玻璃卡片（半透明底 + 卡片区域背景模糊），分三个区域。卡片之间 8（`Metrics.cardGap`）。**外边距不是常数，跟随 Hyprland `gaps_out` 伸缩**：
`外边距 = max(设计最小值, gaps_out + 偏移)`，横向偏移 +5、纵向偏移 +2（设计最小值左右 15、上下 12，
即 gaps=10 下的取值；换大 gaps 配置或大屏时自动内收，四边与窗口间隙保持同一节律）：

- **纵向**：窗口高 = 上下边距 + 卡片高 + 底部补偿，独占区 = 窗口高。
  屏幕顶 → 卡片顶 = 上边距；Hyprland 在独占区边界会再补一次 `gaps_out`，因此卡片底到首个窗口顶
  要多留 `max(0, 上下边距 − gaps_out)` 的透明条；按上式边距恒 ≥ gaps_out + 2，补偿恒为 2，
  卡片底 → 窗口顶正好等于上边距（不叠双间隙，上下视觉一致）。
- **横向**：卡片距屏幕左/右各一个外边距，卡片之间 8。
- **左区**：日期时间卡片（日历图标 + 日期 → 时钟图标 + 时间 → ISO 周数徽标 + 星期）、CPU/内存/磁盘三环、
  Kimi 矢量标 + 7 天/5 小时额度环（各自跟自己的重置倒计时）、DeepSeek 余额，各一张卡片。
- **中区**：工作区环卡片（数量随 Hyprland 工作区动态），卡片中心严格锚定屏幕水平中心（`anchors.horizontalCenter`，不使用等分布局近似）。
- **右区**：一张状态卡片，从左到右依次为主题切换按钮、白噪音按钮（波形圆圈矢量，点击展开声音列表弹层）、
  麦克风静音、音量环（环心 `V`）、亮度环（环心 `L`）、
  电池环（环心 `B`，插电含满电维持时环心为闪电矢量图标）（设备缺失自动隐藏）；代理/网络/蓝牙三枚状态图标另占一张卡片（点击展开控制面板）。

## 4. 视觉规范

统一「环形用量图标」：外环轨道 + 进度弧 + 中央字母/数字；进度弧用 `Shape + PathAngleArc` 绘制，
`preferredRendererType: Shape.CurveRenderer`（抗锯齿内置，不依赖窗口多重采样）。

状态卡图标为 24×24 自绘矢量（与环同高；20×20 绘制视框等比放大，不依赖字体 codepoint）：麦克风（静音为斜线）。
音量/亮度/电池无前置图标，状态由环 + 环心字母/图标表达；环心矢量图标用 `PathSvg` 填充绘制（viewBox 1024），颜色跟随环色。

状态图标卡：网络/蓝牙沿用 Nerd Font 字形（盒 24、字形 22），代理改为 24×24 自绘矢量派生图标：
共同的「地球」底形 + 右下角模式徽标——规则=列表线、全局=小圆环、直连=斜向箭头；徽标用不透明
底色切口与底形分离（毛玻璃卡片下透明切口无法真正切断底形，切口必须不透明）。随 `Proxy.mode` 切换，
未知模式或不可用时只画灰地球（无徽标）。麦克风静音斜线两侧的切口同理。

| 元素 | 值 |
| --- | --- |
| 顶栏窗口高度 | 上下边距 + 卡片高 + 底部补偿，三项各自按 1/DPR 吸附到整设备像素（1.6 缩放下 11.875 + 31.875 + 1.875 = 45.625 = 73 设备像素，buffer 落在整行不再被合成器重采样） |
| 卡片 | 高 32（默认，`barHeight`）、圆角 12、横向内边距 10；底色 base 72% 透明。高度下限由工作区槽位 30 决定，不得低于 32 |
| 卡片边缘 | 深色主题用暗边：1px crust 40% 描边 + 顶部 1px 内高光 text 6%（亮描边叠在模糊光晕上会显"脏边"）；浅色主题 text 本身是深色，保持 1px text 10% 描边不加高光。卡片填充与描边同走 `Shape + CurveRenderer`（与环同一路径）：Rectangle 描边在分段缩放下的圆角 AA 叠着模糊背景会"发毛"（1px 与卡片宽度同按 1/DPR 吸附，描边内收半线宽压在边界内） |
| 毛玻璃 | 卡片区域经 ext-background-effect-v1 请求背景模糊（Hyprland 0.57 原生支持，不需要 layerrule）；卡片底透明度不低于 70%，无模糊时保证可读性 |
| 卡片间隙 / 屏边距 | 8 / `max(设计最小值, gaps_out + 偏移)`：横向最小 15 +5、纵向最小 12 +2（间隙同按 1/DPR 吸附，卡片左边逐项落在像素网格上） |
| 环外径 / 线宽 | 24 / 3（按设备像素吸附：1.6 缩放下实际 23.75 / 3.125） |
| 工作区槽位 / 工作区环 / 线宽 | 30 / 20 / 3（内环小于普通环，在槽位内垂直居中） |
| 当前工作区外圈 | 直径 26 / 线宽 2（peach，居中于 30px 槽位） |
| 字号 | 14（全部文字）；状态卡环心固定 14、不按字符数缩放：音量 `V`、亮度 `L`、电池 `B`（插电时为闪电矢量图标） |
| 状态图标盒 / 字形 | 24 / 22（代理/网络/蓝牙；代理为 24×24 矢量派生图标） |
| 状态卡图标 | 麦克风 24×24 自绘矢量（与环同高），正常 text、静音 overlay |
| 主题按钮 | 高 22、圆角 6、1px 描边、文字 14；宽度随本地化文案 |
| 控制面板 | 宽 400、圆角 12、内边距 12、tab 高 30；最大高 640（随屏高收缩） |
| 面板字号 | 数值/标题 13、正文/标签 12、次要信息 11；tab 标签 12 |
| 代理模式按钮 | 高 30、圆角 8，图标 16 + 文字 13 居中并排 |
| 状态卡模块间距 | 10 |
| 品牌矢量标宽 | 22（鲸标、K 标） |
| 主字体 | `JetBrainsMono Nerd Font` → `JetBrains Mono` → `Noto Sans CJK SC` → `Alibaba PuHuiTi 3.0` → `sans-serif` |

配色全部取自 Catppuccin 官方色板（Mocha `#1e1e2e` 底 / Latte `#eff1f5` 底）。**分层编码原则**：sky 是仪表的
"常态色"（用量环、工作区窗口段）与状态语义（图标"已连接"）；**peach 是唯一的"注意色"**——当前工作区焦点、
用量类环 ≥80% 提醒、电池 <50% 提醒；静态信息去彩色化（text/subtext）。

| 用途 | Mocha 角色 | Latte 角色 |
| --- | --- | --- |
| CPU / 内存 / 磁盘 | 用量两档：<80% sky、≥80% peach | 同左 |
| 音量 | sky（静音时 overlay） | 同左 |
| 亮度 | sky | sky |
| 电池（环与环心字母/图标） | 电量两档：≥50% sky、<50% peach；充电不覆盖，环心改闪电图标、颜色仍按电量分档 | 同左 |
| 状态卡图标（麦克风） | 正常 text、静音 overlay | 同左 |
| 日期时间卡日历/时钟图标 | subtext（静态信息去彩色） | 同左 |
| 日期时间卡周数徽标 | subtext 描边矩形（透明底）+ subtext 数字（实底药丸在毛玻璃上突兀） | 同左 |
| Kimi 额度环（7 天 / 5 小时 / 月度 / 代码） | 与资源环同一套用量两档：<80% sky、≥80% peach | 同左 |
| Kimi 矢量标 | 官方三色：黑底 `#000000` + 白 K `#FFFFFF` + 蓝点 `#1683FF` | 同左 |
| DeepSeek 矢量标 | 官方品牌色 `#4d6bfe`（非 Catppuccin 角色）；不可用 overlay、余额不足 warning | 同左 |
| 工作区窗口色段 | sky（有窗口的槽位） | sky |
| 工作区空槽 | subtext（与日历图标同色，独立 `workspaceTrack` token；比 surface 轨道更醒目，弱化"缺口"感） | 同左 |
| 工作区可见起点半径线 | red | red |
| 当前工作区 | 外圈用 peach 色描边（直径 26、线宽 2，毛玻璃上比 maroon 亮一档，焦点可跳出） | 同左 |
| 环轨道 | 用量类环（资源 / Kimi 额度）空槽：surface2 约 70% 透明（独立 `ringTrack` token，不动全局 track/trackDim；过淡会在毛玻璃上与卡片底融成一片，空槽需保持可读）；工作区环空槽另走 `workspaceTrack` | 同左 |
| 状态图标（代理正常） | sky | sky |
| 状态图标（蓝牙已连接） | sky | sky |
| 状态图标（Wi-Fi 已连接） | sky | sky |
| 状态图标（已开启未连接） | subtext | 同左 |
| 状态图标（不可用/关闭） | overlay（灰） | overlay |

工作区环改为按 scrolling 窗口顺序排列的五段色环，不再按窗口数量分档配色或显示填充进度：

- 环的五个逻辑槽位各 72°，每段可见弧线两端各留 5°（合计 10° 空隙，弧长 62°），一个窗口对应一段。段间空隙不绘制色段或轨道；空槽显示轨道色弧段。活动窗口色段中心始终在 12 点方向，切换活动窗口或左右移动窗口时整体连续旋转，首尾状态未变时不播放动画。
- `N < 5` 时显示全部窗口；`N >= 5` 时始终显示五段。`N > 5` 时可见起点为 `max(1, 活动位置 - 4)`（活动位置从 1 开始），显示其后的连续五个窗口，其余直接隐藏，不显示 `+N` 或其他溢出标记。
- red 半径线连接圆心与最左可见色段的左边界，并随色环整体旋转；活动窗口为第五个或更后面时，该线位于活动色段右侧的段间空隙。
- 所有有窗口的槽位统一使用 sky，不区分应用、不提供按应用自定义颜色；空槽使用 subtext（与日历图标同色）。

## 5. 数据源与刷新策略

| 模块 | 来源 | 刷新 | 不可用时 |
| --- | --- | --- | --- |
| 工作区 | `Quickshell.Hyprland` 事件模型（工作区、顶层窗口、活动窗口与布局顺序） | 事件驱动 | 隐藏 |
| CPU | `/proc/stat` 两次采样求差 | 1s | 显示 `--` |
| 内存 | `/proc/meminfo`（`MemAvailable`） | 2s | `--` |
| 磁盘 | `statvfs("/")` 或 `df -P /` | 30s | `--` |
| 音量 | `Quickshell.Services.Pipewire` | 事件 | 隐藏 |
| 麦克风 | `Quickshell.Services.Pipewire`（`defaultAudioSource`） | 事件 | 隐藏 |
| 白噪音 | 本地 `assets/sounds/` 音频，QtMultimedia `MediaPlayer` 无限循环；选择与音量持久化于 `config.json` | 选中即播 | 按钮置灰 |
| 亮度 | `brightnessctl -m` | 1s | 隐藏 |
| 电池 | `Quickshell.Services.UPower`（`displayDevice`） | 事件 | 隐藏 |
| Kimi 额度 | `GET https://api.kimi.com/coding/v1/usages` | 60s | 灰环 + `--` |
| DeepSeek 余额 | `GET https://api.deepseek.com/user/balance` | 60s | `--` |
| 代理 | mihomo `GET /configs`、`GET /proxies` | 5s | 灰图标 |
| Wi-Fi | `iwctl`（已验证普通用户可读写） | 10s + 面板内即时 | 图标离线 |
| 蓝牙 | `Quickshell.Bluetooth` | 事件 | 隐藏 |

HTTP 统一用 `curl` 子进程（已安装）：`--max-time 8` + 显式 header，解析失败只记日志不抛错。

### 5.1 Kimi 额度

- 接口未公开，已发生过一次结构变更（`usage` → `usages`），解析器必须宽容：优先读 `usages.{limit_5h,limit_7d,limit_month_total,limit_month_code}` 的 `used_ratio`/`reset_time`；`limits[].detail`（5h 窗口 `window.duration=300`）与顶层 `usage`（周额度）只补齐 `usages` 缺失的窗口，避免同一窗口重复画环。
- **窗口动态渲染**：解析器不硬编码窗口集合，顶栏取窗顺序固定为 `7d → 5h → month_total → month_code → 未知窗口`；最多渲染前两个（“双窗口环”），只有一个窗口时只画一个环。所有窗口环与资源环共用一套用量两档配色（<80% sky、≥80% peach）；7 天与 5 小时是固定取窗顺序，月/代码窗口仅作缺失时的回退，不会被丢弃。
- 倒计时由 `reset_time` 计算：7 天窗口按天显示（`1D` / `3D`，不足一天也算 `1D`），5 小时窗口按小时显示（`3H`）；每个环后面紧跟自己的重置倒计时标签（颜色用 text），`hover` 明细给出该窗口的百分比与重置时间。
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
| 工作区环 | 非当前工作区：切换；当前工作区：无操作 | — | hover 显示窗口数 |
| 系统三环 | 打开控制面板 | — | hover 显示明细 |
| 音量环（环心 `V`） | 静音切换 | 调节音量 | hover 显示百分比 |
| 亮度环（环心 `L`） | — | 调节亮度 | hover 显示百分比 |
| 电池环（环心 `B`/插电闪电） | — | — | hover 显示剩余时间/功率；环与环心按电量分档着色 |
| 主题按钮 | dark → light → auto 循环切换 | — | hover 显示当前模式 |
| 白噪音按钮 | 开关声音列表弹层 | — | 播放中 sky、停止 subtext；hover 显示当前声音名 |
| 麦克风 | 切换默认输入源静音 | — | 静音时图标加斜线并变灰，hover 显示状态 |
| 状态图标 | 打开控制面板（对应 tab） | — | 异常时变灰（与 §5「不可用」一致）；代理图标随 `Proxy.mode` 换派生图标 |
| 时钟 | — | — | hover 显示完整日期 |

控制面板：全屏 `PanelWindow` overlay（Overlay 层、忽略独占区）承载，面板实际锚定顶栏右下方；宽 400，
高随内容在 140–640 之间收缩；tab = 代理 / 网络 / 蓝牙；`Esc` 或点击外部关闭；打开时独占键盘焦点
（网络 tab 密码输入需要），关闭后归还。代理 tab 的模式按钮高 30，图标 + 文字并排显示三种模式。

白噪音弹层：下拉 `PanelWindow` overlay，锚定状态卡下方右侧；8 个环境音选项（末位「安静」即停止），
选中项 sky 高亮并立即循环播放、写入持久化，弹层保持打开；底部音量滑条实时调整白噪音音量
（0–1，不影响系统音量），松手持久化；`Esc` 或点击外部关闭。重启后自动续播上次的选择与音量。
详见 `docs/specs/whitenoise/spec.md`。

## 7. 主题与语言

- 主题三态：`dark`（Mocha，默认）/ `light`（Latte）/ `auto`。auto 按本机时间决定：06:00–18:00 用 light，
  其余用 dark，跨过边界后自动生效；持久化到 `~/.config/vbc-io/config.json` 的 `theme`
  （存 `mocha`/`latte`/`auto`，兼容旧值）。主题按钮与 IPC `theme set` 均支持三态。
- 语言：`zh-CN`（默认）/ `en`，切换即时生效；所有可见文案走 `I18n` 单例，日期/星期格式在 `I18n` 内格式化。
  - 日期时间卡按「日历图标 + 日期 → 时钟图标 + 时间 → ISO 周数徽标 + 星期」分组展示，中英均 24 小时制。
  - zh：`11月1日` / `21:26` / `45` / `周一`；en：`1 Nov` / `21:26` / `45` / `Mon`（`45` 为 ISO 周数徽标）。
- 配置项：`theme`、`language`、`barHeight`（卡片高，28–64，默认 32；顶栏总高 = 上下边距 + barHeight + 底部补偿）、`mihomoConfigPath`、`mihomoController`/`mihomoSecret`（配置读取失败时回退）、`secretsPath`。

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
| 合成器不支持 ext-background-effect-v1 | 毛玻璃退化为半透明无模糊，复杂壁纸下可读性下降 | 卡片底透明度不低于 70%；Hyprland 0.57 原生支持该协议（已实测） |
