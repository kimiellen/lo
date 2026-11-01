pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// 链路状态：ip -br addr 只读采样（网卡名 / 状态 / 地址），5s 刷新
Singleton {
    id: root

    property var links: []      // [{ name, state, addresses: [string] }]
    property bool available: false

    Process {
        id: readProcess
        command: ["ip", "-br", "addr"]
        stdout: StdioCollector {
            id: readOutput
            waitForEnd: true
            onStreamFinished: root.apply(readOutput.text)
        }
        onExited: function (exitCode) {
            if (exitCode !== 0)
                root.markUnavailable();
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    function refresh() {
        if (!readProcess.running)
            readProcess.running = true;
    }

    function apply(text) {
        const list = [];
        const lines = (text || "").split("\n");
        for (let i = 0; i < lines.length; ++i) {
            const line = lines[i].trim();
            if (line === "")
                continue;
            const parts = line.split(/\s+/);
            if (parts.length < 2 || parts[0] === "lo")
                continue;
            const addresses = [];
            let skipMetric = false;
            for (let j = 2; j < parts.length; ++j) {
                if (parts[j] === "metric") {
                    skipMetric = true;
                    continue;
                }
                if (skipMetric) {
                    skipMetric = false;
                    continue;
                }
                if (parts[j].indexOf("/") >= 0)
                    addresses.push(parts[j]);
            }
            list.push({ name: parts[0], state: parts[1], addresses: addresses });
        }
        links = list;
        available = true;
    }

    function markUnavailable() {
        links = [];
        available = false;
    }
}
