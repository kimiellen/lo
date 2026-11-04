# whitenoise 任务清单

> 进度事实源。完成一项勾一项；一个里程碑完成后，已完成的里程碑整段归档到 `tasks-archive.md`。

## M2：按钮与弹层 UI

- [ ] `components/NoiseGlyph.qml`：9 个 PathSvg 矢量（按钮波形圆圈 + 8 个列表项图标）— 验证：真机目视
- [ ] `bar/StatusControls.qml`：主题按钮后插入白噪音按钮（播放 sky / 停止 subtext，hover 显示当前声音）— 验证：真机目视
- [ ] `panels/NoisePopup.qml` + `shell.qml` 宿主：下拉弹层（Catppuccin 底、sky 高亮、选中对勾、底部音量滑条、Esc/点外关闭）— 验证：真机目视 + 交互
- [ ] 同步 `docs/specs/topbar/spec.md` §3/§5/§6（spec-change 说明）— 验证：diff 自查
- [ ] 真机验证 dark/light 双主题、8 项切换、滑条音量、重启恢复 — 验证：`qs -c vbc-io`
