pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

// DeepSeek 余额：GET /user/balance，60s 轮询
// 只有金额没有分母，不画环；无 key / 401 / 超时 / 解析失败显示 --，不阻塞顶栏。
Singleton {
    id: root

    readonly property string endpoint: "https://api.deepseek.com/user/balance"

    property string total: ""          // 保留接口原样的字符串金额
    property string currency: "CNY"
    property bool sufficient: true     // is_available；false 时仍显示金额但用警告色
    property bool configured: false
    property bool available: false
    property bool loading: false
    property string error: ""          // key / insecure / auth / unreachable / parse
    property string token: ""          // 当前使用的 key，只驻留内存（不写日志）
    property bool pendingRefresh: false

    Component.onCompleted: {
        Secrets.reload();
        root.refresh();
    }

    Connections {
        target: Secrets

        function onLoadedChanged() {
            if (!Secrets.loaded)
                return;
            const force = root.pendingRefresh;
            root.pendingRefresh = false;
            if (force)
                root.refresh();
            else
                root.refreshIfChanged();
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        // 60s 定时刷新；重读 secrets 后强制刷新，key 变化由 refreshIfChanged 兜底
        onTriggered: {
            root.pendingRefresh = true;
            Secrets.reload();
        }
    }

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
        const env = (Quickshell.env("DEEPSEEK_API_KEY") || "").trim();
        if (env !== "")
            return env;
        return Secrets.get("deepseek_api_key");
    }

    // ---------------- 刷新调度 ----------------

    function refresh() {
        if (root.loading)
            return;

        const key = root.resolveKey();
        if (key === "") {
            root.token = "";
            root.configured = false;
            root.available = false;
            root.total = "";
            root.error = Secrets.insecure ? "insecure" : "key";
            return;
        }

        root.token = key;
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

    // secrets 重读后只在 key 真正变化时刷新，避免额外请求
    function refreshIfChanged() {
        const key = root.resolveKey();
        if (key !== root.token || (key === "" && Secrets.insecure && root.error !== "insecure"))
            root.refresh();
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
        root.total = "";
        root.error = reason;
        if (changed)
            console.warn("quota.deepseek: " + reason);
    }

    function applyPayload(text) {
        let data = null;
        try {
            data = JSON.parse(text);
        } catch (e) {
            data = null;
        }
        if (!data || typeof data !== "object" || !Array.isArray(data.balance_infos)
                || data.balance_infos.length === 0) {
            root.markFailure("parse");
            return;
        }
        const info = data.balance_infos[0];
        if (!info || typeof info !== "object") {
            root.markFailure("parse");
            return;
        }
        const value = info.total_balance === undefined || info.total_balance === null
            ? "" : String(info.total_balance).trim();
        if (value === "" || !isFinite(Number(value))) {
            root.markFailure("parse");
            return;
        }
        root.total = value;
        root.currency = typeof info.currency === "string" && info.currency !== "" ? info.currency : "CNY";
        root.sufficient = data.is_available !== false;
        root.available = true;
        root.error = "";
    }
}
