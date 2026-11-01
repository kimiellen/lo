pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// 背光状态：brightnessctl -m 每秒采样，滚轮写入经去抖合并为一次 set ±N%
Singleton {
    id: root

    property real level: 0              // 0..1
    property bool available: false
    property string device: ""
    property int _pendingPercent: 0
    property bool _refreshPending: false

    function clamp01(v) {
        if (!isFinite(v))
            return 0;
        return Math.max(0, Math.min(1, v));
    }

    function markUnavailable() {
        level = 0;
        available = false;
    }

    // ---------------- 读（1s） ----------------
    Process {
        id: readProcess
        command: ["brightnessctl", "-m"]

        stdout: StdioCollector {
            id: readOutput
            waitForEnd: true
            onStreamFinished: root.readText(readOutput.text)
        }

        onExited: function (exitCode) {
            if (exitCode !== 0)
                root.markUnavailable();
            // 读取期间又有刷新请求时，等本次结束后再补一次，避免拿到写之前的旧值
            if (root._refreshPending) {
                root._refreshPending = false;
                root.refresh();
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    function refresh() {
        if (readProcess.running) {
            _refreshPending = true;
            return;
        }
        readProcess.running = true;
    }

    // 末行格式：device,class,current,percent%,max（不同版本尾部字段可能更多）
    function readText(text) {
        const lines = (text || "").trim().split("\n");
        const fields = lines[lines.length - 1].trim().split(",");
        if (fields.length < 4) {
            markUnavailable();
            return;
        }
        const current = Number(fields[2]);
        let percent = NaN;
        let percentIndex = -1;
        for (let i = 3; i < fields.length; ++i) {
            if (fields[i].endsWith("%")) {
                percent = Number(fields[i].slice(0, -1));
                percentIndex = i;
                break;
            }
        }
        // 百分比字段后紧跟 max（0.5 版为 5 字段；尾部更多字段时仍取相邻值）
        let max = percentIndex >= 0 && fields.length > percentIndex + 1
            ? Number(fields[percentIndex + 1]) : NaN;
        if (!(max > 0) && percent > 0 && current > 0)
            max = current * 100 / percent;

        let value = NaN;
        if (current >= 0 && max > 0)
            value = current / max;
        else if (percent >= 0)
            value = percent / 100;
        if (!isFinite(value)) {
            markUnavailable();
            return;
        }
        device = fields[0];
        level = clamp01(value);
        available = true;
    }

    // ---------------- 写（滚轮去抖） ----------------
    Process {
        id: writeProcess

        // 本机 brightnessctl 写 sysfs 后会以非 0 退出（EPROTO）但亮度已生效，
        // 因此不看退出码，写后一律重读
        onExited: function (exitCode) {
            root.refresh();
        }
    }

    Timer {
        id: writeTimer
        interval: 70
        onTriggered: root.flush()
    }

    function adjust(delta) {
        if (!available)
            return;
        _pendingPercent = Math.max(-50, Math.min(50, _pendingPercent + Math.round(delta * 100)));
        if (_pendingPercent !== 0)
            writeTimer.restart();
    }

    function flush() {
        if (_pendingPercent === 0)
            return;
        if (writeProcess.running) {
            writeTimer.restart();
            return;
        }
        const percent = _pendingPercent;
        _pendingPercent = 0;
        writeProcess.command = ["brightnessctl", "set",
            Math.abs(percent) + "%" + (percent > 0 ? "+" : "-")];
        writeProcess.running = true;
    }
}
