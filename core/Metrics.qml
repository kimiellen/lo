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
    readonly property int ringSize: 24
    readonly property int ringThickness: 3
    readonly property int ringLetterSize: 11

    // 工作区槽位（外描边）与内环
    readonly property int workspaceCell: 26
    readonly property int workspaceRing: 20

    // 文本
    readonly property int textSize: 13         // 时钟、金额、数字
    readonly property int textSizeSmall: 11    // 单位、倒计时

    // 状态图标
    readonly property int iconSize: 22
    readonly property int iconGlyphSize: 17
}
