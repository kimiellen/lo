import QtQuick
import qs.core

// 顶栏卡片：半透明毛玻璃圆角矩形，宽度随内容；背景模糊由 Bar 的 BackgroundEffect 统一申请
// 每张卡片只放一个内容组件，卡片尺寸取该组件的隐式尺寸
Item {
    id: root

    default property alias content: holder.data
    property real radius: Metrics.cardRadius
    property real padding: Metrics.cardPadding   // 横向内边距；纵向由内容居中留白

    readonly property Item contentItem: holder.children.length > 0 ? holder.children[0] : null

    implicitWidth: (contentItem ? contentItem.implicitWidth : 0) + root.padding * 2
    implicitHeight: contentItem ? contentItem.implicitHeight : 0

    Rectangle {
        id: background
        anchors.fill: parent
        radius: root.radius
        color: Theme.glass
        border.width: 1
        border.color: Theme.glassBorder
    }

    Item {
        id: holder
        anchors.fill: parent
        anchors.leftMargin: root.padding
        anchors.rightMargin: root.padding
    }
}
