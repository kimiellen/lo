pragma Singleton
import QtQuick
import Quickshell

// 顶栏尺寸语言：卡片、环、字号、外边距的唯一来源（配色见 Theme）
Singleton {
    id: root

    // 卡片
    readonly property int cardRadius: 18
    readonly property int cardPadding: 10      // 横向内边距；纵向由内容居中留白

    // 栏内布局：卡片之间 8；顶栏四周留白左右 15、上下 12
    readonly property int cardGap: 8
    readonly property int outerMarginX: 15
    readonly property int outerMarginY: 12

    // 环形指标
    readonly property int ringSize: 26
    readonly property int ringThickness: 3
    readonly property int ringLetterSize: 15

    // 工作区槽位（外描边）与内环
    readonly property int workspaceCell: 26
    readonly property int workspaceRing: 20

    // 文本
    readonly property int textSize: 15         // 全部文字：时钟、金额、环外倒计时/单位

    // 状态图标
    readonly property int iconSize: 26         // 状态图标点击/绘制盒
    readonly property int iconGlyphSize: 20     // 盒内 Nerd Font 字形
    readonly property int brandMarkWidth: 24    // 品牌矢量标（鲸标/K 标）逻辑宽度

    // 右区状态卡：自绘图标、主题按钮、模块间距
    readonly property int statusGlyphSize: 20
    readonly property int modeButtonHeight: 24
    readonly property int modeButtonRadius: 6
    readonly property int modeButtonPadding: 8
    readonly property int statusModuleGap: 10   // 模块之间
    readonly property int statusIconGap: 4      // 图标与环之间

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

    // 顶栏纵向几何（Bar 与 Panel 共用，避免两处公式漂移）
    function barMarginY(dpr) {
        return snap(outerMarginY, dpr);
    }

    function barCardHeight(height, dpr) {
        return snap(height, dpr);
    }

    function barWindowHeight(height, gapsOut, dpr) {
        const margin = barMarginY(dpr);
        const bottomPad = Math.max(0, snap(margin - gapsOut, dpr));
        return barCardHeight(height, dpr) + margin + bottomPad;
    }
}
