# 白噪音（whitenoise）— 规格说明

> 本文件是此 feature 的事实源。方向性变更走 spec-change 协议：先改本文件，再改代码。
> 顶栏整体约定见 `docs/specs/topbar/spec.md`；本 feature 只描述新增部分。

## 1. 目标

在右区状态卡（主题 → 麦克风 → 音量 → 亮度 → 电池）的主题按钮**后面**加一枚白噪音按钮。
点击弹出参考图样式的声音列表弹层：8 个环境音选项 + 底部音量滑条，选中即循环播放，
「安静」即停止。选择结果与音量持久化，重启后自动恢复播放。

成功标准：

- 点按钮出弹层、点选项即出声、拖滑条实时改音量（只影响白噪音，不动系统音量）。
- 重启 Quickshell 后自动续播上次的声音与音量；上次为「安静」则保持安静。
- dark/light 两套主题下弹层底色取 Catppuccin `Theme.panel`，高亮统一 sky。

## 2. 关键决策（已与用户确认）

| 决策点 | 结论 | 理由 |
| --- | --- | --- |
| 弹层形式 | 独立下拉弹层（PanelWindow overlay，锚定状态卡下方右侧） | 与参考图一致；不改动现有三 tab 控制面板结构 |
| 播放引擎 | QtMultimedia `MediaPlayer`（`loops: MediaPlayer.Infinite`） | 纯 QML，本机 qt6-multimedia 6.12 已装；免子进程生命周期管理 |
| 持久化 | `config.json` 增 `whiteNoiseTrack` + `whiteNoiseVolume`，启动恢复 | 白噪音是常驻习惯，重启续播 |
| 列表项图标 | 每项独立自绘矢量（PathSvg，viewBox 1024） | 与参考图一致，沿用项目矢量惯例 |

## 3. 声音清单与资源

音频从 word-atlas 拷入本仓库 `assets/sounds/`（不跨项目引用）：

| key | 中文 | English | 文件 |
| --- | --- | --- | --- |
| stars | 星空音乐 | Starlight | amb-stars.mp3 |
| rain | 雨天图书馆 | Rainy Library | amb-rain.mp3 |
| sea | 清晨海岸 | Morning Coast | amb-sea.mp3 |
| forest | 林间早晨 | Forest Morning | amb-forest.mp3 |
| fire | 夜晚壁炉 | Night Fireplace | amb-fire.mp3 |
| voyage | 远航船舱 | Voyage Cabin | amb-voyage.mp3 |
| cafe | 安静咖啡馆 | Quiet Café | amb-cafe.mp3 |
| none | 安静 | Silent | （无，停止播放） |

列表顺序固定为上表顺序；「安静」在最后一项，选中态表现为停止。

## 4. 交互

| 元素 | 行为 |
| --- | --- |
| 状态卡白噪音按钮 | 左键开关弹层；播放中 sky 色，停止（none）时 subtext 色；hover 显示当前声音名 |
| 弹层列表项 | 左键选中：立即切换循环播放并持久化；弹层保持打开（便于继续调音量） |
| 「安静」项 | 停止播放，持久化为 none |
| 音量滑条 | 拖动实时改白噪音音量（0–1），松手持久化；不影响系统音量 |
| 弹层关闭 | `Esc` 或点击弹层外（与现有 Panel 一致） |

## 5. 视觉

- 按钮：24×24 PathSvg（viewBox 1024，用户提供的波形圆圈 path），播放中 sky / 停止 subtext。
- 弹层：圆角 12、1px `Theme.trackDim` 描边、底色 `Theme.panel`；宽 ~260，高随内容。
- 列表项：高 40、图标 18×18 + 名称；选中项 sky 描边圆角框 + 右侧 sky 对勾（参考图样式），图标与名称 sky 高亮；未选中图标/文字用 subtext/text。
- 音量区：底部「音量」标签 + 滑条，滑条已填充段与手柄 sky，轨道 `Theme.track`。
- 所有文案走 `I18n`，颜色走 `Theme`，与 topbar 红线一致。

## 6. 代码结构

```
services/WhiteNoise.qml   # 单例：音轨模型、MediaPlayer 播放、音量、与 Config 双向同步
components/NoiseGlyph.qml # 列表项 + 按钮矢量图标（PathSvg，kind 参数复用）
panels/NoisePopup.qml     # 下拉弹层（shell.qml 宿主，随每屏 Bar 或单实例）
bar/StatusControls.qml    # 主题按钮后插入白噪音按钮
core/Config.qml           # +whiteNoiseTrack / +whiteNoiseVolume 与 setter
core/I18n.qml             # 8 个音轨名 + tooltip + 音量标签（中英）
assets/sounds/            # 7 个 amb-*.mp3（来自 word-atlas，MIT 项目内复制）
```

规则沿用 topbar：UI 只做绑定，播放副作用只在 `services/WhiteNoise.qml`。

## 7. 风险

| 风险 | 影响 | 缓解 |
| --- | --- | --- |
| qt6-multimedia 未装的环境 | 白噪音不可用 | 服务内检测 MediaPlayer 错误状态，按钮降级为灰 + tooltip 提示；不影响顶栏其余部分 |
| 音频文件缺失 | 某项无声 | 启动时校验文件存在，缺失项在列表中置灰 |
| 恢复播放时机早于音频设备就绪 | 启动短暂无声 | MediaPlayer 自带缓冲重试；失败仅记日志 |
