pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// 系统用量采样：CPU（/proc/stat 两次采样求差）、内存（/proc/meminfo）、磁盘（df -P /）
Singleton {
    id: root

    // CPU：占用比例 0..1，首次采样只建立基线
    property real cpuUsage: 0
    property bool cpuAvailable: false
    property real _prevTotal: -1
    property real _prevIdle: -1

    // 内存：以 MemAvailable 为准（缺字段时用 free+buffers+cached 兜底）
    property real memoryUsage: 0
    property real memoryUsedKb: 0
    property real memoryTotalKb: 0
    property bool memoryAvailable: false

    // 磁盘：/ 的已用 /（已用 + 可用），与 df 的 Use% 同口径
    property real diskUsage: 0
    property real diskUsedKb: 0
    property real diskTotalKb: 0
    property bool diskAvailable: false

    function clamp01(v) {
        if (!isFinite(v))
            return 0;
        return Math.max(0, Math.min(1, v));
    }

    // 采样失败：清空数值并标记不可用（环显示 --，不保留旧进度）
    function markCpuUnavailable() {
        cpuUsage = 0;
        cpuAvailable = false;
    }

    function markMemoryUnavailable() {
        memoryUsage = 0;
        memoryUsedKb = 0;
        memoryTotalKb = 0;
        memoryAvailable = false;
    }

    function markDiskUnavailable() {
        diskUsage = 0;
        diskUsedKb = 0;
        diskTotalKb = 0;
        diskAvailable = false;
    }

    // ---------------- CPU（1s） ----------------
    FileView {
        id: statFile
        path: "/proc/stat"
        preload: true
        printErrors: false

        onLoaded: root.readCpu(statFile.text())
        onTextChanged: root.readCpu(statFile.text())
        onLoadFailed: root.markCpuUnavailable()
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: statFile.reload()
    }

    function readCpu(text) {
        const first = (text || "").split("\n")[0];
        if (first.indexOf("cpu ") !== 0) {
            markCpuUnavailable();
            return;
        }
        const fields = first.trim().split(/\s+/).slice(1).map(Number);
        if (fields.length < 4) {
            markCpuUnavailable();
            return;
        }
        let total = 0;
        for (let i = 0; i < fields.length; ++i) {
            if (isFinite(fields[i]))
                total += fields[i];
        }
        const idle = fields[3] + (isFinite(fields[4]) ? fields[4] : 0);
        // 两次采样之间差值；机器重启导致总量回退时跳过本次
        if (_prevTotal >= 0 && total > _prevTotal && idle >= _prevIdle) {
            cpuUsage = clamp01(1 - (idle - _prevIdle) / (total - _prevTotal));
            cpuAvailable = true;
        }
        _prevTotal = total;
        _prevIdle = idle;
    }

    // ---------------- 内存（2s） ----------------
    FileView {
        id: memFile
        path: "/proc/meminfo"
        preload: true
        printErrors: false

        onLoaded: root.readMemory(memFile.text())
        onTextChanged: root.readMemory(memFile.text())
        onLoadFailed: root.markMemoryUnavailable()
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: memFile.reload()
    }

    function readMemory(text) {
        const values = ({});
        const lines = (text || "").split("\n");
        for (let i = 0; i < lines.length; ++i) {
            const m = lines[i].match(/^(\w+):\s+(\d+)/);
            if (m)
                values[m[1]] = Number(m[2]);
        }
        const total = values.MemTotal;
        let available = values.MemAvailable;
        if (!(available > 0) && values.MemFree !== undefined)
            available = values.MemFree + (values.Buffers || 0) + (values.Cached || 0);
        if (!(total > 0) || !(available >= 0)) {
            markMemoryUnavailable();
            return;
        }
        memoryTotalKb = total;
        memoryUsedKb = Math.max(0, total - available);
        memoryUsage = clamp01(memoryUsedKb / total);
        memoryAvailable = true;
    }

    // ---------------- 磁盘（30s） ----------------
    Process {
        id: diskProcess
        command: ["df", "-P", "/"]

        stdout: StdioCollector {
            id: diskOutput
            waitForEnd: true
            onStreamFinished: root.readDisk(diskOutput.text)
        }

        onExited: function (exitCode) {
            if (exitCode !== 0)
                root.markDiskUnavailable();
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: diskProcess.running = true
    }

    function readDisk(text) {
        const lines = (text || "").trim().split("\n");
        if (lines.length < 2) {
            markDiskUnavailable();
            return;
        }
        // 末行：Filesystem 1024-blocks Used Available Capacity Mounted
        const fields = lines[lines.length - 1].trim().split(/\s+/);
        if (fields.length < 4) {
            markDiskUnavailable();
            return;
        }
        const used = Number(fields[2]);
        const available = Number(fields[3]);
        // df 在磁盘写满时 Available 为 0，仍应视为可用（显示 100%）
        if (!(used >= 0) || !(available >= 0) || !(used + available > 0)) {
            markDiskUnavailable();
            return;
        }
        diskUsedKb = used;
        diskTotalKb = used + available;
        diskUsage = clamp01(used / diskTotalKb);
        diskAvailable = true;
    }
}
