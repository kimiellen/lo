pragma Singleton
import QtQuick
import Quickshell
import qs.core

// Catppuccin Mocha / Latte 双色板与语义角色（唯一配色来源）
Singleton {
    id: root

    readonly property var palettes: ({
        mocha: {
            base: "#1e1e2e", mantle: "#181825", crust: "#11111b",
            text: "#cdd6f4", subtext: "#a6adc8", overlay: "#6c7086",
            surface0: "#313244", surface1: "#45475a", surface2: "#585b70",
            rosewater: "#f5e0dc", flamingo: "#f2cdcd", pink: "#f5c2e7", mauve: "#cba6f7",
            red: "#f38ba8", maroon: "#eba0ac", peach: "#fab387",
            yellow: "#f9e2af", green: "#a6e3a1", teal: "#94e2d5",
            sky: "#89dceb", sapphire: "#74c7ec", blue: "#89b4fa", lavender: "#b4befe"
        },
        latte: {
            base: "#eff1f5", mantle: "#e6e9ef", crust: "#dce0e8",
            text: "#4c4f69", subtext: "#6c6f85", overlay: "#9ca0b0",
            surface0: "#ccd0da", surface1: "#bcc0cc", surface2: "#acb0be",
            rosewater: "#dc8a78", flamingo: "#dd7878", pink: "#ea76cb", mauve: "#8839ef",
            red: "#d20f39", maroon: "#e64553", peach: "#fe640b",
            yellow: "#df8e1d", green: "#40a02b", teal: "#179299",
            sky: "#04a5e5", sapphire: "#209fb5", blue: "#1e66f5", lavender: "#7287fd"
        }
    })

    readonly property var p: Config.effectiveTheme === "latte" ? palettes.latte : palettes.mocha

    // 语义角色
    readonly property color bg: p.base
    readonly property color panel: p.mantle
    readonly property color text: p.text
    readonly property color subtext: p.subtext
    readonly property color overlay: p.overlay
    readonly property color track: p.surface1
    readonly property color trackDim: p.surface0

    // 顶栏卡片：不透明底色 + 1px 细描边（描边透明度走 opacity，避免在 QML 里做颜色通道运算）
    readonly property color cardBg: bg
    readonly property real cardBorderOpacity: 0.12

    // fontconfig 负责字体替换与 CJK 回退，这里只给首选族名
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property string fontFamilyFallback: "Noto Sans Mono CJK SC"

    // 资源固定配色
    readonly property color cpu: p.blue
    readonly property color memory: p.mauve
    readonly property color disk: p.teal
    readonly property color volume: p.green
    readonly property color brightness: p.yellow
    // 电池分档：<20% 红 / 20–60% 黄 / ≥60% 绿；充电统一 green
    readonly property color batteryLow: p.red
    readonly property color batteryMid: p.yellow
    readonly property color batteryHigh: p.green
    readonly property color charging: p.green
    readonly property color success: p.green
    readonly property color warning: p.red
    readonly property color accent: p.lavender
    // 额度模块：DeepSeek 用官方品牌色（非 Catppuccin 角色）；
    // Kimi 7 天窗口 sapphire、5 小时窗口 flamingo，月度/代码等回退窗口沿用 pink
    readonly property color deepseekBrand: "#4d6bfe"
    readonly property color kimiWeek: p.sapphire
    readonly property color kimiSession: p.flamingo
    readonly property color kimi: p.pink

    // 电池状态色：充电优先 green，其余按电量分三档
    function batteryColor(ratio, isCharging) {
        if (isCharging)
            return charging;
        if (ratio < 0.2)
            return batteryLow;
        if (ratio < 0.6)
            return batteryMid;
        return batteryHigh;
    }

    // 工作区窗口数分档：0 / 1-2 / 3-4 / 5+
    function workspaceColor(windows) {
        if (windows <= 0)
            return p.overlay;
        if (windows <= 2)
            return p.blue;
        if (windows <= 4)
            return p.yellow;
        return p.red;
    }
}
