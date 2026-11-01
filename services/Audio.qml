pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// 音频状态：默认输出节点的音量与静音（Pipewire 事件驱动）
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool available: sink !== null && sink.ready && sink.audio !== null
    readonly property real volume: available ? clamp01(sink.audio.volume) : 0
    readonly property bool muted: available ? sink.audio.muted : false

    // 未被 track 的节点不会收到属性更新（volume 恒为 0、volumes 为空）
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    function clamp01(v) {
        if (!isFinite(v))
            return 0;
        return Math.max(0, Math.min(1, v));
    }

    function setVolume(value) {
        if (!available)
            return;
        sink.audio.volume = clamp01(value);
    }

    // 滚轮调节；调高音量视为取消静音（与常见桌面行为一致）
    function adjustVolume(delta) {
        if (!available)
            return;
        const audio = sink.audio;
        audio.volume = clamp01(audio.volume + delta);
        if (audio.muted && delta > 0)
            audio.muted = false;
    }

    function toggleMute() {
        if (!available)
            return;
        sink.audio.muted = !sink.audio.muted;
    }
}
