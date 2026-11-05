import QtQuick
import QtQuick.Shapes
import QtQuick.Window
import qs.core

// 顶栏卡片：低噪毛玻璃 + 实色外框，外框与玻璃填充分层绘制，宽度随内容
// 每张卡片只放一个内容组件，卡片尺寸取该组件的隐式尺寸；宽度与外框按设备像素吸附
// 两层均走 Shape + CurveRenderer；模糊区域通过 outerRadius 复用可见外轮廓
Item {
    id: root

    default property alias content: holder.data
    property real radius: Metrics.cardRadius
    property real padding: Metrics.cardPadding   // 横向内边距；纵向由内容居中留白

    readonly property Item contentItem: holder.children.length > 0 ? holder.children[0] : null
    // 真实设备像素比（分段缩放下 Screen.devicePixelRatio 只返回整数）
    readonly property real dpr: Window.window ? Window.window.devicePixelRatio : 1
    readonly property real frameWidth: Metrics.snap(1, root.dpr)
    // 外轮廓落在整设备像素；内层减去同样的宽度与半径，保持圆角同心
    readonly property real outerRadius: Metrics.snap(root.radius, root.dpr)

    // 卡片宽度吸附到整设备像素：卡片左右边与间隙都落在像素网格上
    implicitWidth: Metrics.snap((contentItem ? contentItem.implicitWidth : 0) + root.padding * 2, root.dpr)
    implicitHeight: contentItem ? contentItem.implicitHeight : 0

    component RoundedFill: Item {
        id: shape

        property real inset: 0
        property real radius: 0
        property color color

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                id: path

                readonly property real left: shape.inset
                readonly property real top: shape.inset
                readonly property real right: shape.width - shape.inset
                readonly property real bottom: shape.height - shape.inset
                readonly property real r: shape.radius

                strokeWidth: 0
                fillColor: shape.color

                startX: path.left + path.r
                startY: path.top

                PathLine { x: path.right - path.r; y: path.top }
                PathArc { x: path.right; y: path.top + path.r; radiusX: path.r; radiusY: path.r }
                PathLine { x: path.right; y: path.bottom - path.r }
                PathArc { x: path.right - path.r; y: path.bottom; radiusX: path.r; radiusY: path.r }
                PathLine { x: path.left + path.r; y: path.bottom }
                PathArc { x: path.left; y: path.bottom - path.r; radiusX: path.r; radiusY: path.r }
                PathLine { x: path.left; y: path.top + path.r }
                PathArc { x: path.left + path.r; y: path.top; radiusX: path.r; radiusY: path.r }
            }
        }
    }

    // 实色外框覆盖整个外轮廓；其内侧抗锯齿下方不再是模糊背景
    RoundedFill {
        anchors.fill: parent
        radius: root.outerRadius
        color: Theme.cardBorder
    }

    RoundedFill {
        anchors.fill: parent
        inset: root.frameWidth
        radius: root.outerRadius - root.frameWidth
        color: Theme.cardBg
    }

    Item {
        id: holder
        anchors.fill: parent
        anchors.leftMargin: root.padding
        anchors.rightMargin: root.padding
    }
}
