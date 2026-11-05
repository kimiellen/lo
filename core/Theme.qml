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
    // 环轨道：surface2 约 70% 透明（过淡会在毛玻璃上与卡片底融成一片；实色则喧宾夺主）
    readonly property color ringTrack: Qt.rgba(p.surface2.r, p.surface2.g, p.surface2.b, 0.7)

    // 顶栏卡片：毛玻璃——base 72% 透明（无模糊时仍保证可读性）
    readonly property color cardBg: Qt.rgba(bg.r, bg.g, bg.b, 0.72)
    // 边缘：深色主题用不透明暗边（crust——半透明描边会透出背后模糊边缘的噪点，拐角发毛）+ 顶部 1px 内高光；
    // 浅色主题 text 本身是深色，保持 text 10% 描边、不加高光
    readonly property color cardBorder: Config.effectiveTheme === "latte"
        ? Qt.rgba(text.r, text.g, text.b, 0.10)
        : p.crust
    readonly property color cardHighlight: Config.effectiveTheme === "latte"
        ? "transparent"
        : Qt.rgba(text.r, text.g, text.b, 0.06)
    // 图标切口底色：必须不透明，半透明切口无法切断下方字形（毛玻璃底下尤其明显）
    readonly property color cardCut: bg

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
    readonly property color noise: p.sky
    readonly property color success: p.green
    readonly property color warning: p.red
    readonly property color accent: p.lavender
    // 额度模块：DeepSeek 用官方品牌色（非 Catppuccin 角色）
    readonly property color deepseekBrand: "#4d6bfe"

    // 工作区窗口段统一 sky，空槽用轨道色；选中工作区的外圈用 peach（唯一焦点色，毛玻璃上比 maroon 亮一档）
    readonly property color workspace: p.sky
    readonly property color workspaceFocus: p.peach

    // 时钟卡片：日历/时钟图标去彩色（subtext，静态信息）；周数徽标同色系描边 + 数字（实底药丸在毛玻璃上突兀）
    readonly property color clockDate: p.subtext
    readonly property color clockTime: p.subtext
    readonly property color weekBadge: p.subtext
    readonly property color weekBadgeText: p.subtext

    // 用量类环两档：<80% sky（常态）、≥80% peach（注意色）；资源环与 Kimi 额度环共用
    function usageColor(ratio) {
        return ratio >= 0.8 ? p.peach : p.sky;
    }

    // 电池两档：≥50% sky、<50% peach（充电不覆盖，仍按电量分档）
    function batteryColor(ratio) {
        return ratio >= 0.5 ? p.sky : p.peach;
    }
}
