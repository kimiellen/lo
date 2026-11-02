pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

// 额度密钥文件：只读 secrets.json，权限必须是 600/400；内容只驻留内存，不写日志
Singleton {
    id: root

    property var values: ({})
    property bool loaded: false      // 一次读取流程结束（成功或失败）
    property bool missing: false     // 文件不存在 / 不可读 / 非 JSON
    property bool insecure: false    // 权限过宽，拒绝读取
    property bool busy: false

    readonly property string path: Config.secretsPath

    property bool _warnedInsecure: false

    Process {
        id: statProcess
        command: ["stat", "-c", "%a", root.path]

        stdout: StdioCollector {
            id: statOutput
            waitForEnd: true
        }

        stderr: StdioCollector {
            id: statError
            waitForEnd: true
        }

        onExited: function (exitCode) {
            if (exitCode !== 0) {
                root.finishMissing();
                return;
            }
            const mode = statOutput.text.trim();
            // 只接受 owner-only 的权限；更宽的模式一律不读，避免把密钥暴露给同组/其他用户
            if (mode !== "600" && mode !== "400") {
                root.busy = false;
                root.missing = false;
                root.insecure = true;
                root.values = ({});
                root.loaded = true;
                if (!root._warnedInsecure) {
                    root._warnedInsecure = true;
                    console.warn("secrets: " + root.path + " must be mode 600 (found " + mode + ")");
                }
                return;
            }
            readProcess.running = true;
        }
    }

    Process {
        id: readProcess
        command: ["cat", root.path]

        stdout: StdioCollector {
            id: readOutput
            waitForEnd: true
        }

        stderr: StdioCollector {
            id: readError
            waitForEnd: true
        }

        onExited: function (exitCode) {
            if (exitCode !== 0) {
                root.finishMissing();
                return;
            }
            let data = null;
            try {
                // 有些编辑器会写入 UTF-8 BOM
                data = JSON.parse(readOutput.text.replace(/^\uFEFF/, ""));
            } catch (e) {
                data = null;
            }
            root.busy = false;
            root.insecure = false;
            if (!data || typeof data !== "object") {
                root.values = ({});
                root.missing = true;
            } else {
                root.values = data;
                root.missing = false;
            }
            // 必须最后置 loaded：监听者收到信号时 values/missing/insecure 已是最终值
            root.loaded = true;
        }
    }

    function finishMissing() {
        root.busy = false;
        root.missing = true;
        root.insecure = false;
        root.values = ({});
        root.loaded = true;
    }

    function reload() {
        if (root.busy)
            return;
        root.busy = true;
        root.loaded = false;
        root.missing = false;
        root.insecure = false;
        statProcess.running = true;
    }

    function get(key) {
        if (!root.values)
            return "";
        const value = root.values[key];
        return typeof value === "string" ? value.trim() : "";
    }
}
