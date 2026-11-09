# whitenoise 已完成里程碑归档

## M1：服务层与资源 ✅

- [x] 拷贝 7 个 `amb-*.mp3` → `assets/sounds/`
- [x] `core/Config.qml`：新增 `whiteNoiseTrack` / `whiteNoiseVolume` 持久化
- [x] `core/I18n.qml`：8 个音轨名 + tooltip + 音量标签（中英）
- [x] `services/WhiteNoise.qml`：音轨模型 + `MediaPlayer` 无限循环 + 音量 + 启动恢复 + 非法 key 回退 none
- [x] 验证（临时探针 + `VBCIO_CONFIG_DIR` 隔离目录，已清理）：PipeWire 出现 quickshell 播放流；
  select("rain") 即播、setVolume(0.33) 生效并落盘；重启进程 initial=rain/0.33 自动续播；
  bogus key 回退 none 不报错

## M2：按钮与弹层 UI ✅

- [x] `components/NoiseGlyph.qml`：9 个 PathSvg 矢量（按钮波形圆圈用用户提供的 viewBox 1024 path，8 个列表项图标自绘）
- [x] `bar/StatusControls.qml`：主题按钮后插入白噪音按钮（track≠none 时 sky / none 时 subtext，tooltip 显示当前声音名）
- [x] `panels/NoisePopup.qml` + `shell.qml` 宿主：下拉弹层（`Theme.panel` 底、sky 选中框 + 对勾、底部音量滑条、Esc/点外关闭）；
  滑条拖动走 `WhiteNoise.previewVolume` 实时生效、松手 `commitVolume` 落盘（服务加了 liveVolume 临时值，避免拖动频繁写 config.json）
- [x] 同步 `docs/specs/topbar/spec.md` §3/§5/§6（spec-change 已经用户确认）
- [x] 真机验证（`qs -c vbc-io` + grim 截图）：dark/light 双主题弹层与按钮渲染正常；点 Starlight 即播、
  点 Silent 即停且写盘 `whiteNoiseTrack: "none"`；外部改 config 为 rain 触发热加载续播 rain；
  音量滑条拖动实时跟随；重启进程无 QML 报错、none 保持安静

## M3：音频开源授权合规替换 ✅

- [x] 授权调研：旧 `amb-*.mp3`（word-atlas 来源）全部替换；新音频选自 GitHub 开源项目
  [Blanket](https://github.com/rafaelmardojai/blanket)，仅收录 CC0 / 公有领域条目（免署名），
  CC BY 条目（Rain/Waves/Storm/City/Train）剔除；逐条来源记录于 `assets/sounds/LICENSES.md`
- [x] `assets/sounds/`：7 个 `amb-*.ogg`（birds/stream/wind/night/fire/boat/cafe，ffprobe + ffmpeg 解码校验通过，
  Blanket 按循环规范剪辑、无缝循环），删除全部旧 mp3；格式 mp3 → ogg
- [x] `services/WhiteNoise.qml`：trackKeys 改为新清单，扩展名 .mp3 → .ogg；旧 config 中的失效 key 自动回退 none
- [x] `components/NoiseGlyph.qml`：图标 kind 适配新音轨（新增 birds 飞鸟 / stream 波浪 / wind 风线 / night 弯月，
  fire/cafe 复用，voyage 改名 boat）
- [x] `core/I18n.qml`：中英音轨文案更新
- [x] spec-change 经用户确认后先行更新 `docs/specs/whitenoise/spec.md` §3/§6
- [x] 验证：`qs -p ~/.config/lo` 启动无 QML 报错、多媒体 ffmpeg 后端正常加载；菜单切轨出声待真机目视确认
