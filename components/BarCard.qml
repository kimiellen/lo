import QtQuick
import QtQuick.Window
import qs.core

// 顶栏卡片：不透明底色 + 1px 描边的圆角矩形，宽度随内容
// 每张卡片只放一个内容组件，卡片尺寸取该组件的隐式尺寸；宽度与描边按设备像素吸附
Item {
    id: root

    default property alias content: holder.data
    property real radius: Metrics.cardRadius
    property real padding: Metrics.cardPadding   // 横向内边距；纵向由内容居中留白

    readonly property Item contentItem: holder.children.length > 0 ? holder.children[0] : null
    // 真实设备像素比（分段缩放下 Screen.devicePixelRatio 只返回整数）
    readonly property real dpr: Window.window ? Window.window.devicePixelRatio : 1

    // 卡片宽度吸附到整设备像素：卡片左右边与间隙都落在像素网格上，描边才不出现 1/2px 交替
    implicitWidth: Metrics.snap((contentItem ? contentItem.implicitWidth : 0) + root.padding * 2, root.dpr)
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
        border.width: Metrics.snap(1, root.dpr)
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
