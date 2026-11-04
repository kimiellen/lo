pragma Singleton
import QtQuick
import Quickshell

// 顶栏尺寸语言：卡片、环、字号、外边距的唯一来源（配色见 Theme）
Singleton {
    id: root

    // 卡片
    readonly property int cardRadius: 16
    readonly property int cardPadding: 10      // 横向内边距；纵向由内容居中留白

    // 栏内布局：卡片之间 8；顶栏四周留白 = max(设计最小值, gaps_out + 偏移)，
    // 跟随 Hyprland gaps_out 伸缩，换显示器/改 gaps 配置无需手调（见 spec §3）
    readonly property int cardGap: 8
    readonly property int outerMarginX: 15        // 设计最小值
    readonly property int outerMarginY: 12
    readonly property int outerMarginGapOffsetX: 5
    readonly property int outerMarginGapOffsetY: 2

    // 环形指标
    readonly property int ringSize: 24
    readonly property int ringThickness: 3
    readonly property int ringLetterSize: 14

    // 工作区槽位（外描边）与内环；内环小于普通环，给五段断弧留呼吸
    readonly property int workspaceCell: 30
    readonly property int workspaceRing: 20
    readonly property int workspaceRingThickness: 3
    readonly property int workspaceFocusRing: 26
    readonly property int workspaceFocusRingThickness: 2
    readonly property int workspaceSegmentGap: 10

    // 文本
    readonly property int textSize: 14         // 全部文字：时钟、金额、环外倒计时/单位

    // 状态图标
    readonly property int iconSize: 24         // 状态图标点击/绘制盒
    readonly property int iconGlyphSize: 22     // 盒内字形/矢量图标（光学尺寸对齐）
    readonly property int brandMarkWidth: 22    // 品牌矢量标（鲸标/K 标）逻辑宽度

    // 时钟卡片：日历/时钟矢量图标、图标与文字间距、分组间距（周数徽标复用 modeButton* 药丸尺寸）
    readonly property int clockIconSize: root.modeButtonHeight  // 与周数药丸等高
    readonly property int clockIconTextGap: 5
    readonly property int clockGroupGap: 10

    // 右区状态卡：自绘图标（与环同高）、主题按钮、模块间距
    readonly property int statusGlyphSize: 24
    readonly property int modeButtonHeight: 22
    readonly property int modeButtonRadius: 6
    readonly property int modeButtonPadding: 8
    readonly property int statusModuleGap: 10   // 模块之间

    // 控制面板：宽 400、内边距 12、tab 高 30；字号 11–13
    readonly property int panelWidth: 400
    readonly property int panelRadius: 12
    readonly property int panelPadding: 12
    readonly property int panelTabHeight: 30
    readonly property int panelTitleSize: 13     // 数值/名称
    readonly property int panelTextSize: 12      // 正文/标签
    readonly property int panelMetaSize: 11      // 次要信息
    readonly property int proxyModeButtonHeight: 30
    readonly property int proxyModeIconSize: 16

    // 设备像素吸附：逻辑尺寸 × DPR 常是小数（分段缩放 1.6 下 26 → 41.6），
    // 几何落在半像素上就会发虚。DPR 必须由调用方传入（取 Window.window.devicePixelRatio，
    // Screen.devicePixelRatio 在分段缩放下只返回整数，不可用）。
    function snap(px, dpr) {
        return Math.round(px * dpr) / dpr;
    }

    // 吸附到偶数设备像素：圆/环直径用它，左右边界才能同时落在整像素上
    function snapEven(px, dpr) {
        return Math.max(2, 2 * Math.round(px * dpr / 2)) / dpr;
    }

    // 顶栏外边距：不小于设计最小值，且始终比 gaps_out 大固定偏移，
    // 这样 Hyprland 在独占区边界补的 gaps_out 永远不会顶穿顶栏的间隙节律
    function outerMarginXFor(gapsOut) {
        return Math.max(outerMarginX, gapsOut + outerMarginGapOffsetX);
    }

    function outerMarginYFor(gapsOut) {
        return Math.max(outerMarginY, gapsOut + outerMarginGapOffsetY);
    }

    // 顶栏纵向几何（Bar 与 Panel 共用，避免两处公式漂移）
    function barMarginY(gapsOut, dpr) {
        return snap(outerMarginYFor(gapsOut), dpr);
    }

    function barCardHeight(height, dpr) {
        return snap(height, dpr);
    }

    function barWindowHeight(height, gapsOut, dpr) {
        const margin = barMarginY(gapsOut, dpr);
        const bottomPad = Math.max(0, snap(outerMarginYFor(gapsOut) - gapsOut, dpr));
        return barCardHeight(height, dpr) + margin + bottomPad;
    }
}
