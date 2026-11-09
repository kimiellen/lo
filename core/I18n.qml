pragma Singleton
import QtQuick
import Quickshell
import qs.core

// 文案与日期格式：中英双语单例（所有可见文字的唯一来源）
Singleton {
    id: root

    readonly property bool isZh: Config.language === "zh"

    readonly property var zh: ({
        "app.name": "vbc-Io",
        "tooltip.workspaces": "工作区",
        "tooltip.cpu": "CPU 占用",
        "tooltip.memory": "内存占用",
        "tooltip.disk": "磁盘占用",
        "tooltip.volume": "音量",
        "tooltip.brightness": "亮度",
        "tooltip.battery": "电池",
        "tooltip.proxy": "代理",
        "tooltip.network": "网络",
        "tooltip.bluetooth": "蓝牙",
        "panel.proxy": "代理",
        "panel.network": "网络",
        "panel.bluetooth": "蓝牙",
        "panel.scan": "扫描",
        "panel.connect": "连接",
        "panel.disconnect": "断开",
        "panel.cancel": "取消",
        "panel.password": "密码",
        "panel.password.placeholder": "输入 Wi-Fi 密码",
        "panel.known": "已保存",
        "panel.connected": "已连接",
        "panel.link": "链路",
        "panel.link.empty": "无链路信息",
        "panel.wifi": "Wi-Fi",
        "panel.wifi.off": "Wi-Fi 已关闭",
        "panel.wifi.idle": "未连接",
        "panel.wifi.empty": "未发现网络",
        "panel.wifi.scanning": "扫描中…",
        "panel.wifi.failed": "连接失败",
        "panel.wifi.unsupported": "不支持的加密方式",
        "panel.wifi.unavailable": "Wi-Fi 不可用",
        "panel.bt.unavailable": "蓝牙不可用",
        "panel.bt.off": "蓝牙已关闭",
        "panel.bt.empty": "未发现设备",
        "panel.bt.available": "可用设备",
        "panel.bt.paired": "已配对",
        "panel.bt.discovering": "搜索中…",
        "panel.bt.search": "搜索",
        "panel.bt.battery": "电量",
        "panel.proxy.mode": "模式",
        "panel.proxy.rule": "规则",
        "panel.proxy.global": "全局",
        "panel.proxy.direct": "直连",
        "panel.proxy.node": "当前节点",
        "panel.proxy.group": "策略组",
        "panel.proxy.tun": "TUN",
        "panel.proxy.tun.on": "已开启",
        "panel.proxy.tun.off": "已关闭",
        "panel.proxy.switching": "切换中…",
        "panel.proxy.failed": "切换失败",
        "panel.proxy.refresh": "刷新",
        "panel.proxy.unavailable": "mihomo 不可用",
        "panel.proxy.unavailable.hint": "external-controller 无响应",
        "panel.proxy.noConfig": "未找到 mihomo 配置",
        "panel.proxy.noConfig.hint": "检查 mihomoConfigPath 或 config.json",
        "panel.proxy.auth": "secret 缺失或错误",
        "panel.proxy.auth.hint": "检查 mihomo 配置的 secret",
        "status.connected": "已连接",
        "status.on": "已开启",
        "status.unavailable": "不可用",
        "quota.kimi": "Kimi 额度",
        "quota.kimi.5h": "5 小时额度",
        "quota.kimi.7d": "7 天额度",
        "quota.kimi.month": "月度额度",
        "quota.kimi.code": "代码额度",
        "quota.kimi.5h.short": "5 小时",
        "quota.kimi.7d.short": "7 天",
        "quota.kimi.month.short": "月度",
        "quota.kimi.code.short": "代码",
        "quota.deepseek": "DeepSeek 余额",
        "quota.deepseek.low": "余额不足",
        "quota.noKey": "未配置 API key",
        "quota.insecure": "secrets.json 权限过宽",
        "quota.auth": "API key 无效",
        "quota.offline": "接口不可用",
        "quota.parse": "返回数据无法解析",
        "quota.loading": "同步中…",
        "wifi.security.psk": "WPA",
        "wifi.security.open": "开放",
        "wifi.security.8021x": "802.1X",
        "wifi.security.wep": "WEP",
        "ring.cpu": "C",
        "ring.memory": "M",
        "ring.disk": "D",
        "tooltip.muted": "静音",
        "tooltip.charging": "充电中",
        "tooltip.full": "已充满",
        "theme.dark": "深色",
        "theme.light": "浅色",
        "theme.auto": "自动",
        "tooltip.theme": "主题",
        "tooltip.mic": "麦克风",
        "tooltip.mic.muted": "已静音",
        "tooltip.mic.on": "已开启",
        "tooltip.noise": "白噪音",
        "noise.volume": "音量",
        "noise.birds": "林间鸟鸣",
        "noise.stream": "溪流潺潺",
        "noise.wind": "原野风声",
        "noise.night": "夏夜虫鸣",
        "noise.fire": "夜晚壁炉",
        "noise.boat": "远航船舱",
        "noise.cafe": "安静咖啡馆",
        "noise.none": "安静",
        "common.na": "--"
    })

    readonly property var en: ({
        "app.name": "vbc-Io",
        "tooltip.workspaces": "Workspaces",
        "tooltip.cpu": "CPU usage",
        "tooltip.memory": "Memory usage",
        "tooltip.disk": "Disk usage",
        "tooltip.volume": "Volume",
        "tooltip.brightness": "Brightness",
        "tooltip.battery": "Battery",
        "tooltip.proxy": "Proxy",
        "tooltip.network": "Network",
        "tooltip.bluetooth": "Bluetooth",
        "panel.proxy": "Proxy",
        "panel.network": "Network",
        "panel.bluetooth": "Bluetooth",
        "panel.scan": "Scan",
        "panel.connect": "Connect",
        "panel.disconnect": "Disconnect",
        "panel.cancel": "Cancel",
        "panel.password": "Password",
        "panel.password.placeholder": "Wi-Fi password",
        "panel.known": "Saved",
        "panel.connected": "Connected",
        "panel.link": "Links",
        "panel.link.empty": "No link data",
        "panel.wifi": "Wi-Fi",
        "panel.wifi.off": "Wi-Fi is off",
        "panel.wifi.idle": "Not connected",
        "panel.wifi.empty": "No networks",
        "panel.wifi.scanning": "Scanning…",
        "panel.wifi.failed": "Connection failed",
        "panel.wifi.unsupported": "Unsupported security",
        "panel.wifi.unavailable": "Wi-Fi unavailable",
        "panel.bt.unavailable": "Bluetooth unavailable",
        "panel.bt.off": "Bluetooth is off",
        "panel.bt.empty": "No devices",
        "panel.bt.available": "Available",
        "panel.bt.paired": "Paired",
        "panel.bt.discovering": "Searching…",
        "panel.bt.search": "Search",
        "panel.bt.battery": "Battery",
        "panel.proxy.mode": "Mode",
        "panel.proxy.rule": "Rule",
        "panel.proxy.global": "Global",
        "panel.proxy.direct": "Direct",
        "panel.proxy.node": "Node",
        "panel.proxy.group": "Group",
        "panel.proxy.tun": "TUN",
        "panel.proxy.tun.on": "On",
        "panel.proxy.tun.off": "Off",
        "panel.proxy.switching": "Switching…",
        "panel.proxy.failed": "Switch failed",
        "panel.proxy.refresh": "Refresh",
        "panel.proxy.unavailable": "mihomo unavailable",
        "panel.proxy.unavailable.hint": "external-controller not responding",
        "panel.proxy.noConfig": "mihomo config not found",
        "panel.proxy.noConfig.hint": "Check mihomoConfigPath or config.json",
        "panel.proxy.auth": "secret missing or invalid",
        "panel.proxy.auth.hint": "Check the mihomo secret",
        "status.connected": "connected",
        "status.on": "on",
        "status.unavailable": "unavailable",
        "quota.kimi": "Kimi quota",
        "quota.kimi.5h": "5-hour quota",
        "quota.kimi.7d": "7-day quota",
        "quota.kimi.month": "Monthly quota",
        "quota.kimi.code": "Code quota",
        "quota.kimi.5h.short": "5h",
        "quota.kimi.7d.short": "7d",
        "quota.kimi.month.short": "month",
        "quota.kimi.code.short": "code",
        "quota.deepseek": "DeepSeek balance",
        "quota.deepseek.low": "Balance low",
        "quota.noKey": "API key not set",
        "quota.insecure": "secrets.json permissions too open",
        "quota.auth": "Invalid API key",
        "quota.offline": "API unavailable",
        "quota.parse": "Unparseable response",
        "quota.loading": "Syncing…",
        "wifi.security.psk": "WPA",
        "wifi.security.open": "Open",
        "wifi.security.8021x": "802.1X",
        "wifi.security.wep": "WEP",
        "ring.cpu": "C",
        "ring.memory": "M",
        "ring.disk": "D",
        "tooltip.muted": "Muted",
        "tooltip.charging": "Charging",
        "tooltip.full": "Full",
        "theme.dark": "dark",
        "theme.light": "light",
        "theme.auto": "auto",
        "tooltip.theme": "Theme",
        "tooltip.mic": "Microphone",
        "tooltip.mic.muted": "Muted",
        "tooltip.mic.on": "On",
        "tooltip.noise": "White noise",
        "noise.volume": "Volume",
        "noise.birds": "Forest Birds",
        "noise.stream": "Stream",
        "noise.wind": "Open Wind",
        "noise.night": "Summer Night",
        "noise.fire": "Night Fireplace",
        "noise.boat": "Boat Cabin",
        "noise.cafe": "Quiet Café",
        "noise.none": "Silent",
        "common.na": "--"
    })

    readonly property var dict: isZh ? zh : en

    function t(key) {
        const v = dict[key];
        return v === undefined ? key : v;
    }

    // iwctl 的安全类型 token → 展示文案；未知类型原样返回
    function securityLabel(token) {
        const v = dict["wifi.security." + (token || "").toLowerCase()];
        return v === undefined ? (token || "") : v;
    }

    // mihomo mode → 展示文案（rule / global / direct）
    function proxyMode(mode) {
        const v = dict["panel.proxy." + (mode || "")];
        return v === undefined ? (mode || "") : v;
    }

    // 额度重置倒计时：2H 后重置 / resets in 2H
    function resetIn(text) {
        if (!text)
            return "";
        return isZh ? text + " 后重置" : "resets in " + text;
    }

    readonly property var weekdayZh: ["日", "一", "二", "三", "四", "五", "六"]
    readonly property var weekdayEn: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    readonly property var monthEn: ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    function two(n) {
        return n < 10 ? "0" + n : "" + n;
    }

    // 时钟卡片分组文案：zh: 11月1日 / 21:26 / 周一；en: 1 Nov / 21:26 / Mon
    function formatClockDate(d) {
        if (!d)
            return "";
        if (isZh)
            return (d.getMonth() + 1) + "月" + d.getDate() + "日";
        return d.getDate() + " " + monthEn[d.getMonth()];
    }

    function formatClockTime(d) {
        if (!d)
            return "";
        return two(d.getHours()) + ":" + two(d.getMinutes());
    }

    function formatClockWeekday(d) {
        if (!d)
            return "";
        return isZh ? "周" + weekdayZh[d.getDay()] : weekdayEn[d.getDay()];
    }

    // ISO 8601 周数：周一为一周之始，含首个周四的周为第 1 周
    function isoWeek(d) {
        if (!d)
            return 0;
        const thu = new Date(d.getFullYear(), d.getMonth(), d.getDate());
        thu.setDate(thu.getDate() + 3 - ((thu.getDay() + 6) % 7));
        const week1 = new Date(thu.getFullYear(), 0, 4);
        week1.setDate(week1.getDate() + 3 - ((week1.getDay() + 6) % 7));
        return 1 + Math.round((thu - week1) / 604800000);
    }
}
