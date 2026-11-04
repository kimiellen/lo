# whitenoise 已完成里程碑归档

## M1：服务层与资源 ✅

- [x] 拷贝 7 个 `amb-*.mp3` → `assets/sounds/`
- [x] `core/Config.qml`：新增 `whiteNoiseTrack` / `whiteNoiseVolume` 持久化
- [x] `core/I18n.qml`：8 个音轨名 + tooltip + 音量标签（中英）
- [x] `services/WhiteNoise.qml`：音轨模型 + `MediaPlayer` 无限循环 + 音量 + 启动恢复 + 非法 key 回退 none
- [x] 验证（临时探针 + `VBCIO_CONFIG_DIR` 隔离目录，已清理）：PipeWire 出现 quickshell 播放流；
  select("rain") 即播、setVolume(0.33) 生效并落盘；重启进程 initial=rain/0.33 自动续播；
  bogus key 回退 none 不报错
