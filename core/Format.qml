pragma Singleton
import QtQuick
import Quickshell

// 数值格式化：百分比、倒计时、金额（展示层统一口径）
Singleton {
    id: root

    function clamp01(v) {
        if (!isFinite(v))
            return 0;
        return Math.max(0, Math.min(1, v));
    }

    function percent(v) {
        return Math.round(clamp01(v) * 100) + "%";
    }

    // 毫秒 → 2H / 1D / 3D；无效或过期返回空串
    function countdown(ms) {
        if (!(ms > 0))
            return "";
        const hours = ms / 3600000;
        if (hours >= 24)
            return Math.round(hours / 24) + "D";
        return Math.max(1, Math.round(hours)) + "H";
    }

    // 金额：保留接口原样的整数/两位小数
    function money(value, currency) {
        if (value === undefined || value === null || value === "")
            return "--";
        const symbol = currency === "USD" ? "$" : (currency === "CNY" || !currency ? "¥" : currency + " ");
        return symbol + value;
    }

    // 环形用量值：窗口数封顶映射，避免 >5 个窗口把环画爆
    function ratio(value, max) {
        if (!(max > 0))
            return 0;
        return clamp01(value / max);
    }

    // 容量：KiB → GiB（保留一位小数）
    function size(kb) {
        if (!(kb > 0))
            return "--";
        return (kb / 1048576).toFixed(1) + " GiB";
    }
}
