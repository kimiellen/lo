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

    // 资源固定配色：统一 sky 强调色（电池仍按电量分档）
    readonly property color cpu: p.sky
    readonly property color memory: p.sky
    readonly property color disk: p.sky
    readonly property color proxy: p.sky
    readonly property color network: p.sky
    readonly property color bluetooth: p.sky
    readonly property color volume: p.sky
    readonly property color brightness: p.sky
    // 电池分档：<40% 红 / 40–70% 黄 / ≥70% 绿（充电不覆盖，仍按电量分档）
    readonly property color batteryLow: p.red
    readonly property color batteryMid: p.yellow
    readonly property color batteryHigh: p.green
    readonly property color success: p.green
    readonly property color warning: p.red
    readonly property color accent: p.lavender
    // 额度模块：DeepSeek 用官方品牌色（非 Catppuccin 角色）；Kimi 所有窗口环统一 sky
    readonly property color deepseekBrand: "#4d6bfe"
    readonly property color kimi: p.sky

    // 工作区窗口段统一 sky，空槽用轨道色；选中工作区的外圈用 maroon
    readonly property color workspace: p.sky
    readonly property color workspaceFocus: p.maroon

    // 时钟卡片：日历/时钟图标与周数药丸统一 sky；药丸文字按主题取深色保证对比
    readonly property color clockDate: p.sky
    readonly property color clockTime: p.sky
    readonly property color weekBadge: p.sky
    readonly property color weekBadgeText: Config.effectiveTheme === "latte" ? p.text : p.crust

    // 电池状态色：按电量分三档（<40% 红 / 40–70% 黄 / ≥70% 绿），充电不覆盖
    function batteryColor(ratio) {
        if (ratio < 0.4)
            return batteryLow;
        if (ratio < 0.7)
            return batteryMid;
        return batteryHigh;
    }
}
