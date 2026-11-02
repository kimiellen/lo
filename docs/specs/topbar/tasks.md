# topbar 任务清单

> 进度事实源。完成一项勾一项；一个里程碑完成后，已完成的里程碑整段归档到 `tasks-archive.md`。

## M7 卡片化样式与间隙对齐

- [x] `docs/specs/topbar/spec.md`：§2/§3/§4/§7 同步新的布局与视觉规范
- [x] `services/Hypr.qml`：读取 `general:gaps_out`（`hyprctl getoption -j`），暴露 `gapsOut` 供外边距/卡片间隙使用
- [x] `core/Metrics.qml`：卡片/环/字号尺寸 token；`core/Theme.qml` 加毛玻璃底色与描边；`Config.barHeight` 改为卡片高（默认 44）
- [x] `components/GlassCard.qml`：半透明圆角卡片，宽度随内容
- [x] `bar/Bar.qml`：三区卡片布局（7 张卡片），窗口高 = gap + 卡片高，`exclusiveZone` 同值，单一 `BackgroundEffect` 覆盖各卡片圆角区域
- [x] bar item 放大：环 24/3、工作区 26/20、时钟与金额 13、倒计时 11、状态图标 22
- [x] `panels/Panel.qml`：面板 y 跟随新顶栏高度，不与卡片重叠
- [x] 验证：热重载无 QML 报错；截图（Mocha/Latte）目视卡片与毛玻璃；`hyprctl layers` bar 高 54；`hyprctl clients` 窗口 y=66（54 + gaps_out 10 + 边框 2）
