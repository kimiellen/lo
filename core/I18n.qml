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
        "wifi.security.psk": "WPA",
        "wifi.security.open": "开放",
        "wifi.security.8021x": "802.1X",
        "wifi.security.wep": "WEP",
        "ring.cpu": "C",
        "ring.memory": "M",
        "ring.disk": "D",
        "ring.volume": "V",
        "ring.brightness": "B",
        "ring.muted": "×",
        "tooltip.muted": "静音",
        "tooltip.charging": "充电中",
        "tooltip.full": "已充满",
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
        "wifi.security.psk": "WPA",
        "wifi.security.open": "Open",
        "wifi.security.8021x": "802.1X",
        "wifi.security.wep": "WEP",
        "ring.cpu": "C",
        "ring.memory": "M",
        "ring.disk": "D",
        "ring.volume": "V",
        "ring.brightness": "B",
        "ring.muted": "×",
        "tooltip.muted": "Muted",
        "tooltip.charging": "Charging",
        "tooltip.full": "Full",
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

    readonly property var weekdayZh: ["日", "一", "二", "三", "四", "五", "六"]
    readonly property var weekdayEn: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    readonly property var monthEn: ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    function two(n) {
        return n < 10 ? "0" + n : "" + n;
    }

    // zh: 11月1日 - 21:26 - 周一 / en: 1 Nov - 09:26 PM - Mon
    function formatClock(d) {
        if (!d)
            return "";
        if (isZh) {
            return (d.getMonth() + 1) + "月" + d.getDate() + "日 - "
                + two(d.getHours()) + ":" + two(d.getMinutes()) + " - 周"
                + weekdayZh[d.getDay()];
        }
        const h = d.getHours();
        const h12 = ((h + 11) % 12) + 1;
        return d.getDate() + " " + monthEn[d.getMonth()] + " - "
            + two(h12) + ":" + two(d.getMinutes()) + " " + (h < 12 ? "AM" : "PM")
            + " - " + weekdayEn[d.getDay()];
    }
}
