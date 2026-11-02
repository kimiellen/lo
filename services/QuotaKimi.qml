pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

// Kimi Code 额度：GET /coding/v1/usages，60s 轮询
// 解析顺序 usages（复数）→ limits[] → usage（旧版周额度），窗口动态，
// 顶栏最多取前两个；reset_time 转倒计时。任何失败只降级为灰环，不抛错。
Singleton {
    id: root

    readonly property string endpoint: "https://api.kimi.com/coding/v1/usages"

    // 解析后的窗口：[{ id, letter, labelKey, ratio, resetAt }]
    property var windows: []
    property bool configured: false    // 找到了 key（env 或 secrets.json）
    property bool available: false     // 最近一次请求解析成功
    property bool loading: false
    property string error: ""          // key / insecure / auth / unreachable / parse
    property double now: Date.now()    // 倒计时基准，30s 刷新一次
    property string _signature: ""     // 避免数据未变时重建 Repeater（环闪一下）

    readonly property var windowOrder: ["limit_5h", "limit_7d", "limit_month_total", "limit_month_code"]

    // ---------------- 读取 secret ----------------
    Component.onCompleted: {
        Secrets.reload();
        root.refresh();
    }

    Connections {
        target: Secrets

        function onLoadedChanged() {
            if (Secrets.loaded)
                root.refresh();
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            // 环境变量 key 直接刷新；否则每次轮询重读 secrets.json，
            // 这样删除/替换 key 后无需重启即可降级或恢复
            if ((Quickshell.env("KIMI_CODING_API_KEY") || "").trim() === "")
                Secrets.reload();
            else
                root.refresh();
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.now = Date.now()
    }

    // ---------------- 请求 ----------------
    Process {
        id: fetchProcess

        stdout: StdioCollector {
            id: fetchOutput
            waitForEnd: true
        }

        stderr: StdioCollector {
            id: fetchError
            waitForEnd: true
        }

        onExited: function (exitCode) {
            root.loading = false;
            if (exitCode !== 0) {
                root.markFailure("unreachable");
                return;
            }
            const parts = root.splitStatus(fetchOutput.text);
            if (parts.status === 401 || parts.status === 403) {
                root.markFailure("auth");
                return;
            }
            if (parts.status !== 0 && (parts.status < 200 || parts.status >= 300)) {
                root.markFailure("unreachable");
                return;
            }
            root.applyPayload(parts.body);
        }
    }

    function resolveKey() {
        const env = (Quickshell.env("KIMI_CODING_API_KEY") || "").trim();
        if (env !== "")
            return env;
        return Secrets.get("kimi_api_key");
    }

    function refresh() {
        if (root.loading)
            return;

        const key = root.resolveKey();
        if (key === "") {
            root.configured = false;
            root.available = false;
            root.windows = [];
            root.error = Secrets.insecure ? "insecure" : "key";
            return;
        }

        root.configured = true;
        if (root.error === "key" || root.error === "insecure")
            root.error = "";
        root.loading = true;
        fetchProcess.command = [
            "curl", "-sS", "--max-time", "8",
            "-H", "Authorization: Bearer " + key,
            "-H", "Accept: application/json",
            "-w", "\n%{http_code}",
            root.endpoint
        ];
        fetchProcess.running = true;
    }

    function splitStatus(text) {
        // curl -w 会在正文后追加状态码；部分代理还会补换行，先去掉尾部空白
        const body = (text || "").replace(/\s+$/, "");
        const index = body.lastIndexOf("\n");
        if (index < 0)
            return { body: body, status: 0 };
        const tail = body.slice(index + 1).trim();
        if (!/^\d{3}$/.test(tail))
            return { body: body, status: 0 };
        return { body: body.slice(0, index), status: Number(tail) };
    }

    function markFailure(reason) {
        const changed = root.available || root.error !== reason;
        root.available = false;
        root.windows = [];
        root._signature = "";
        root.error = reason;
        if (changed)
            console.warn("quota.kimi: " + reason);
    }

    function applyPayload(text) {
        const parsed = root.parsePayload(text);
        if (parsed === null || parsed.length === 0) {
            root.markFailure("parse");
            return;
        }
        root.now = Date.now();
        const signature = JSON.stringify(parsed);
        if (root.available && signature === root._signature)
            return;
        root._signature = signature;
        root.windows = parsed;
        root.available = true;
        root.error = "";
    }

    // ---------------- 宽容解析 ----------------
    function parsePayload(text) {
        let data = null;
        try {
            data = JSON.parse(text);
        } catch (e) {
            return null;
        }
        if (!data || typeof data !== "object" || Array.isArray(data))
            return null;

        const list = [];

        function has(id) {
            for (let i = 0; i < list.length; ++i) {
                if (list[i].id === id)
                    return true;
            }
            return false;
        }

        function add(id, entry) {
            if (id === "" || has(id))
                return;
            const window = root.buildWindow(id, entry);
            if (window !== null)
                list.push(window);
        }

        // 1) usages（复数）：首选，包含 used_ratio / reset_time
        if (data.usages && typeof data.usages === "object" && !Array.isArray(data.usages)) {
            for (let i = 0; i < root.windowOrder.length; ++i) {
                const key = root.windowOrder[i];
                if (data.usages[key] !== undefined)
                    add(root.windowId(key), data.usages[key]);
            }
            for (const key in data.usages) {
                if (root.windowOrder.indexOf(key) >= 0)
                    continue;
                add(root.windowId(key), data.usages[key]);
            }
        }

        // 2) limits[]：补齐 usages 没给出的窗口（通常是 5h 的绝对 used/limit）
        if (Array.isArray(data.limits)) {
            for (let i = 0; i < data.limits.length; ++i) {
                const item = data.limits[i];
                if (!item || typeof item !== "object")
                    continue;
                const id = root.windowIdFromWindow(item.window);
                add(id, item.detail && typeof item.detail === "object" ? item.detail : item);
            }
        }

        // 3) usage（旧版单数）：顶层周额度
        if (data.usage && typeof data.usage === "object")
            add("7d", data.usage);

        // 固定优先级，未知窗口排在最后
        const known = ["5h", "7d", "month", "code"];
        const ordered = [];
        for (let i = 0; i < known.length; ++i) {
            for (let j = 0; j < list.length; ++j) {
                if (list[j].id === known[i])
                    ordered.push(list[j]);
            }
        }
        for (let i = 0; i < list.length; ++i) {
            if (known.indexOf(list[i].id) < 0)
                ordered.push(list[i]);
        }
        return ordered;
    }

    function windowId(key) {
        if (key === "limit_5h")
            return "5h";
        if (key === "limit_7d")
            return "7d";
        if (key === "limit_month_total")
            return "month";
        if (key === "limit_month_code")
            return "code";
        return String(key);
    }

    function windowIdFromWindow(window) {
        if (!window || typeof window !== "object")
            return "";
        let duration = Number(window.duration);
        if (!isFinite(duration) || duration <= 0)
            return "";
        const unit = window.timeUnit || "";
        if (unit === "TIME_UNIT_HOUR")
            duration *= 60;
        else if (unit === "TIME_UNIT_DAY")
            duration *= 1440;
        else if (unit === "TIME_UNIT_SECOND")
            duration /= 60;
        if (duration === 300)
            return "5h";
        if (duration === 10080)
            return "7d";
        if (duration >= 28000 && duration <= 45000)
            return "month";
        return "w" + Math.round(duration);
    }

    function letterFor(id) {
        if (id === "5h")
            return "5";
        if (id === "7d")
            return "7";
        if (id === "month")
            return "M";
        if (id === "code")
            return "C";
        return "K";
    }

    function labelKeyFor(id) {
        if (id === "5h" || id === "7d" || id === "month" || id === "code")
            return "quota.kimi." + (id === "month" ? "month" : id);
        return "quota.kimi";
    }

    function buildWindow(id, entry) {
        const ratio = root.ratioOf(entry);
        if (ratio < 0)
            return null;
        return {
            id: id,
            letter: root.letterFor(id),
            labelKey: root.labelKeyFor(id),
            ratio: ratio,
            resetAt: root.resetOf(entry)
        };
    }

    function ratioOf(entry) {
        if (!entry || typeof entry !== "object")
            return -1;
        let ratio = entry.used_ratio;
        if (typeof ratio === "string")
            ratio = ratio.trim().replace(/%$/, "");
        if (ratio === undefined || ratio === null) {
            const used = Number(entry.used);
            const limit = Number(entry.limit);
            if (isFinite(used) && isFinite(limit) && limit > 0)
                ratio = used / limit;
        }
        if (ratio === undefined || ratio === null) {
            const remaining = Number(entry.remaining);
            const limit = Number(entry.limit);
            if (isFinite(remaining) && isFinite(limit) && limit > 0)
                ratio = 1 - remaining / limit;
        }
        ratio = Number(ratio);
        if (!isFinite(ratio) || ratio < 0)
            return -1;
        // 兼容误用 0-100 百分数的返回
        if (ratio > 1 && ratio <= 100)
            ratio /= 100;
        return Math.max(0, Math.min(1, ratio));
    }

    function resetOf(entry) {
        if (!entry || typeof entry !== "object")
            return 0;
        let value = entry.reset_time;
        if (value === undefined)
            value = entry.resetTime;
        if (value === undefined)
            value = entry.reset_at;
        return root.parseTime(value);
    }

    function parseTime(value) {
        if (value === undefined || value === null || value === "")
            return 0;
        if (typeof value === "number") {
            if (!isFinite(value) || value <= 0)
                return 0;
            return value > 1e12 ? value : value * 1000;
        }
        const text = String(value).trim();
        if (/^\d+(\.\d+)?$/.test(text)) {
            const number = Number(text);
            if (!isFinite(number) || number <= 0)
                return 0;
            return number > 1e12 ? number : number * 1000;
        }
        // V8 对超过 3 位的小数秒不保证可解析，先截断到毫秒
        const normalized = text.replace(/(\.\d{3})\d+/, "$1");
        const time = Date.parse(normalized);
        return isFinite(time) ? time : 0;
    }
}
