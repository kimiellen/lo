import QtQuick
import qs.core

// 顶栏卡片：不透明底色 + 1px 描边的圆角矩形，宽度随内容
// 每张卡片只放一个内容组件，卡片尺寸取该组件的隐式尺寸
Item {
    id: root

    default property alias content: holder.data
    property real radius: Metrics.cardRadius
    property real padding: Metrics.cardPadding   // 横向内边距；纵向由内容居中留白

    readonly property Item contentItem: holder.children.length > 0 ? holder.children[0] : null

    implicitWidth: (contentItem ? contentItem.implicitWidth : 0) + root.padding * 2
    implicitHeight: contentItem ? contentItem.implicitHeight : 0

    // 底色
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Theme.cardBg
    }

    // 1px 描边（透明度只作用在描边上，因为填充是透明的）
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border.width: 1
        border.color: Theme.text
        opacity: Theme.cardBorderOpacity
    }

    Item {
        id: holder
        anchors.fill: parent
        anchors.leftMargin: root.padding
        anchors.rightMargin: root.padding
    }
}
