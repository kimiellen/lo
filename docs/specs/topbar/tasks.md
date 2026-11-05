# topbar 任务清单

> 进度事实源。完成一项勾一项；一个里程碑完成后，已完成的里程碑整段归档到 `tasks-archive.md`。

## 里程碑：顶栏毛玻璃与视觉分层

- [x] `core/Theme.qml`：`cardBg` 改 base 72% 透明；深色主题不透明 crust 暗边 + 顶部内高光；`ringTrack`（surface2 70%）；`workspaceFocus` maroon → peach；时钟图标 sky → subtext；周数徽标改 subtext 描边矩形；用量环两档（`usageColor` ≥80% peach）、电池两档（≥50% sky / <50% peach）
- [x] `core/Metrics.qml`：`cardRadius` 16 → 12
- [x] `core/Config.qml`：`barHeight` 默认 35 → 32
- [x] `bar/Bar.qml`：恢复 `BackgroundEffect.blurRegion`（按 7 张卡片圆角区域请求背景模糊）
- [x] `components/BarCard.qml`：填充+描边改 `Shape + CurveRenderer` 圆角矩形（修分段缩放下拐角发毛）
- [x] `AGENTS.md`：部署目录硬约束（`~/.config/lo`，禁碰 `~/.config/quickshell`）
- [x] 真机验证：启动无报错、毛玻璃生效、边缘/徽标/空槽对比经三轮目视迭代确认（双主题与双 DPR 留真机复看）
