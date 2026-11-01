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
