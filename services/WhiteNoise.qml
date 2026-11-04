pragma Singleton
import QtQuick
import QtMultimedia
import Quickshell
import qs.core

// 白噪音：环境音无限循环播放（QtMultimedia），音轨与音量经 Config 持久化，启动自动续播
Singleton {
    id: root

    // 顺序即弹层列表顺序；none 固定在最后，表示停止；文案由 UI 走 I18n.t("noise." + key)
    readonly property var trackKeys: ["stars", "rain", "sea", "forest", "fire", "voyage", "cafe", "none"]

    // 配置里出现非法 key（旧版本/手改）时按停止处理
    readonly property string track: trackKeys.indexOf(Config.whiteNoiseTrack) >= 0
        ? Config.whiteNoiseTrack : "none"
    readonly property bool playing: player.playbackState === MediaPlayer.PlayingState
    // 滑条拖动中的临时音量（<0 表示无临时值）；松手才落盘，避免拖动过程频繁写 config.json
    property real liveVolume: -1
    readonly property real volume: liveVolume >= 0 ? liveVolume : Config.whiteNoiseVolume

    function select(key) {
        Config.setWhiteNoiseTrack(trackKeys.indexOf(key) >= 0 ? key : "none");
    }

    function setVolume(v) {
        Config.setWhiteNoiseVolume(v);
    }

    function previewVolume(v) {
        liveVolume = Math.max(0, Math.min(1, v));
    }

    function commitVolume(v) {
        liveVolume = -1;
        Config.setWhiteNoiseVolume(v);
    }

    MediaPlayer {
        id: player

        loops: MediaPlayer.Infinite
        source: root.track === "none" ? "" : Qt.resolvedUrl("../assets/sounds/amb-" + root.track + ".mp3")
        // source 变化即自动播放（含启动续播与切歌）；source 置空即停止
        autoPlay: true

        audioOutput: AudioOutput {
            volume: root.volume
        }

        onErrorOccurred: function (error, errorString) {
            console.warn("WhiteNoise: playback error", error, errorString);
        }
    }
}
