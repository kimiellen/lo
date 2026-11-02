pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

// 代理状态：mihomo external-controller 封装
// 读取 mihomo 配置里的 external-controller / secret，5s 轮询 /configs 与 /proxies，
// 通过 PATCH /configs 切换 mode（mihomo 1.19.33 的 PUT 返回 204 但不生效）；
// secret 只驻留内存，不写日志
Singleton {
    id: root

    property string controller: ""      // http://127.0.0.1:9090
    property string secret: ""
    property bool configured: false      // 找到了 external-controller
    property bool available: false       // 最近一次 /configs 请求成功
    property string mode: ""             // rule / global / direct
    property bool tun: false
    property string node: ""             // 当前节点（策略组递归解析到具体节点）
    property string nodeGroup: ""        // 解析起点策略组
    property bool busy: false            // 切换 mode 进行中
    property bool failed: false          // 最近一次切换失败
    property string error: ""            // config / auth / unreachable / parse
    property string pendingMode: ""

    // ---------------- 读配置 ----------------
    Process {
        id: configProcess
        command: ["cat", Config.mihomoConfigPath]
        stdout: StdioCollector {
            id: configOutput
            waitForEnd: true
        }
        stderr: StdioCollector {
            id: configError
            waitForEnd: true
        }
        onExited: function (exitCode) {
            if (exitCode === 0)
                root.applyConfigText(configOutput.text);
            else
                root.applyFallback();
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // ---------------- 读状态 ----------------
    Process {
        id: configsProcess
        stdout: StdioCollector {
            id: configsOutput
            waitForEnd: true
        }
        stderr: StdioCollector {
            id: configsError
            waitForEnd: true
        }
        onExited: function (exitCode) {
            if (exitCode !== 0) {
                root.markFailure(exitCode);
                return;
            }
            root.applyConfigs(configsOutput.text);
        }
    }

    Process {
        id: proxiesProcess
        stdout: StdioCollector {
            id: proxiesOutput
            waitForEnd: true
        }
        stderr: StdioCollector {
            id: proxiesError
            waitForEnd: true
        }
        onExited: function (exitCode) {
            if (exitCode !== 0)
                return;
            root.applyProxies(proxiesOutput.text);
        }
    }

    // ---------------- 写 mode ----------------
    Process {
        id: putProcess
        stderr: StdioCollector {
            id: putError
            waitForEnd: true
        }
        onExited: function (exitCode) {
            const target = root.pendingMode;
            root.busy = false;
            root.pendingMode = "";
            if (exitCode !== 0) {
                root.failed = true;
                console.warn("proxy: switch mode failed (curl exit " + exitCode + ")");
                root.refresh();
                return;
            }
            root.failed = false;
            if (target !== "")
                root.mode = target;
            root.refresh();
        }
    }

    Component.onCompleted: {
        if (!configProcess.running)
            configProcess.running = true;
    }

    // ---------------- 配置解析 ----------------
    function cleanValue(value) {
        let v = (value || "").replace(/\s+#.*$/, "").trim();
        if (v.length >= 2) {
            const first = v.charAt(0);
            const last = v.charAt(v.length - 1);
            if ((first === "\"" && last === "\"") || (first === "'" && last === "'"))
                v = v.slice(1, -1).trim();
        }
        return v;
    }

    function normalizeController(value) {
        let v = root.cleanValue(value).replace(/\/+$/, "");
        if (v === "")
            return "";
        if (v.startsWith("0.0.0.0:"))
            v = "127.0.0.1:" + v.slice(8);
        else if (v.startsWith("[::]:"))
            v = "127.0.0.1:" + v.slice(5);
        else if (v.startsWith(":"))
            v = "127.0.0.1" + v;
        if (!/^https?:\/\//.test(v))
            v = "http://" + v;
        return v;
    }

    function applyConfigText(text) {
        let ctrl = "";
        let sec = "";
        const lines = (text || "").split("\n");
        for (let i = 0; i < lines.length; ++i) {
            // 只匹配 YAML 顶层键，忽略嵌套的 secret/controller
            let m = /^external-controller\s*:\s*(.*)$/.exec(lines[i]);
            if (m) {
                ctrl = root.cleanValue(m[1]);
                continue;
            }
            m = /^secret\s*:\s*(.*)$/.exec(lines[i]);
            if (m)
                sec = root.cleanValue(m[1]);
        }
        if (ctrl === "")
            ctrl = Config.mihomoController;
        if (sec === "")
            sec = Config.mihomoSecret;
        root.configured = ctrl !== "";
        root.controller = root.normalizeController(ctrl);
        root.secret = sec;
        root.error = root.configured ? "" : "config";
        if (root.configured)
            root.refresh();
    }

    function applyFallback() {
        root.configured = Config.mihomoController !== "";
        root.controller = root.normalizeController(Config.mihomoController);
        root.secret = Config.mihomoSecret;
        root.error = root.configured ? "" : "config";
        if (root.configured)
            root.refresh();
    }

    // ---------------- 请求 ----------------
    function curlArgs(url) {
        const args = ["curl", "-fsS", "--max-time", "8"];
        if (root.secret !== "")
            args.push("-H", "Authorization: Bearer " + root.secret);
        args.push(url);
        return args;
    }

    function refresh() {
        if (!root.configured) {
            // 配置可能稍后才出现，轮询时顺带重读
            if (!configProcess.running)
                configProcess.running = true;
            return;
        }
        if (configsProcess.running)
            return;
        configsProcess.command = root.curlArgs(root.controller + "/configs");
        configsProcess.running = true;
    }

    function applyConfigs(text) {
        let data = null;
        try {
            data = JSON.parse(text);
        } catch (e) {
            root.markFailure("parse");
            return;
        }
        if (!data || typeof data !== "object") {
            root.markFailure("parse");
            return;
        }
        root.mode = data.mode || "";
        root.tun = !!(data.tun && data.tun.enable === true);
        root.available = true;
        root.error = "";
        if (!proxiesProcess.running) {
            proxiesProcess.command = root.curlArgs(root.controller + "/proxies");
            proxiesProcess.running = true;
        }
    }

    function markFailure(reason) {
        const next = (typeof reason === "number")
            ? (reason === 22 ? "auth" : "unreachable")
            : "parse";
        if (root.available || root.error !== next)
            console.warn("proxy: controller request failed (" + next + ")");
        root.available = false;
        root.mode = "";
        root.tun = false;
        root.node = "";
        root.nodeGroup = "";
        root.error = next;
    }

    // ---------------- 节点解析 ----------------
    function resolveChain(proxies, name, depth) {
        if (depth > 6)
            return name;
        const entry = proxies[name];
        if (!entry || !entry.now || entry.now === name)
            return name;
        return root.resolveChain(proxies, entry.now, depth + 1);
    }

    function applyProxies(text) {
        let data = null;
        try {
            data = JSON.parse(text);
        } catch (e) {
            return;
        }
        const proxies = data && data.proxies ? data.proxies : {};

        if (root.mode === "direct") {
            root.node = "DIRECT";
            root.nodeGroup = "";
            return;
        }

        let start = "";
        let group = "";
        if (root.mode === "global" && proxies.GLOBAL && proxies.GLOBAL.now) {
            start = proxies.GLOBAL.now;
            group = "GLOBAL";
        }

        if (start === "") {
            // rule 模式下取成员最多的策略组（即实际出站池），递归解析到具体节点
            let best = null;
            for (const key in proxies) {
                const entry = proxies[key];
                if (!entry || !entry.all || entry.all.length === 0)
                    continue;
                const type = entry.type;
                if (type !== "Selector" && type !== "URLTest"
                    && type !== "Fallback" && type !== "LoadBalance")
                    continue;
                if (best === null || entry.all.length > best.all.length) {
                    best = entry;
                    group = key;
                }
            }
            if (best !== null)
                start = best.name;
        }

        root.nodeGroup = group;
        root.node = start === "" ? "" : root.resolveChain(proxies, start, 0);
    }

    // ---------------- 操作 ----------------
    function setMode(next) {
        if (!root.configured || !root.available || root.busy)
            return;
        if (next !== "rule" && next !== "global" && next !== "direct")
            return;
        if (next === root.mode)
            return;
        root.busy = true;
        root.failed = false;
        root.pendingMode = next;
        const args = root.curlArgs(root.controller + "/configs");
        args.splice(args.length - 1, 0,
            "-X", "PATCH",
            "-H", "Content-Type: application/json",
            "-d", JSON.stringify({ mode: next }));
        putProcess.command = args;
        putProcess.running = true;
    }
}
