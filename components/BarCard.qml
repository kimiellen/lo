import QtQuick
import QtQuick.Shapes
import QtQuick.Window
import qs.core

// 顶栏卡片：毛玻璃（半透明底 + 背景模糊，模糊区域由 Bar 申请）+ 1px 描边的圆角矩形，宽度随内容
// 每张卡片只放一个内容组件，卡片尺寸取该组件的隐式尺寸；宽度与描边按设备像素吸附
// 填充与描边走 Shape + CurveRenderer（与环同一路径）：Rectangle 描边在分段缩放下的
// 圆角 AA 叠着模糊背景会"发毛"
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

    Shape {
        id: cardShape
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: cardPath

            // 描边内收半线宽：描边骑跨路径两侧，内收后外缘正好压在卡片边界上
            readonly property real inset: cardPath.strokeWidth / 2
            readonly property real r: Metrics.snap(root.radius, root.dpr)
            readonly property real right: cardShape.width - inset
            readonly property real bottom: cardShape.height - inset

            strokeWidth: Metrics.snap(1, root.dpr)
            strokeColor: Theme.cardBorder
            fillColor: Theme.cardBg

            startX: cardPath.inset + cardPath.r
            startY: cardPath.inset

            PathLine { x: cardPath.right - cardPath.r; y: cardPath.inset }
            PathArc { x: cardPath.right; y: cardPath.inset + cardPath.r; radiusX: cardPath.r; radiusY: cardPath.r }
            PathLine { x: cardPath.right; y: cardPath.bottom - cardPath.r }
            PathArc { x: cardPath.right - cardPath.r; y: cardPath.bottom; radiusX: cardPath.r; radiusY: cardPath.r }
            PathLine { x: cardPath.inset + cardPath.r; y: cardPath.bottom }
            PathArc { x: cardPath.inset; y: cardPath.bottom - cardPath.r; radiusX: cardPath.r; radiusY: cardPath.r }
            PathLine { x: cardPath.inset; y: cardPath.inset + cardPath.r }
            PathArc { x: cardPath.inset + cardPath.r; y: cardPath.inset; radiusX: cardPath.r; radiusY: cardPath.r }
        }
    }

    // 顶部 1px 内高光（仅深色主题；两端内收一个圆角，避免探出圆角外）
    Rectangle {
        anchors {
            top: parent.top
            topMargin: Metrics.snap(1, root.dpr)
            left: parent.left
            right: parent.right
            leftMargin: root.radius
            rightMargin: root.radius
        }
        height: Metrics.snap(1, root.dpr)
        color: Theme.cardHighlight
    }

    Item {
        id: holder
        anchors.fill: parent
        anchors.leftMargin: root.padding
        anchors.rightMargin: root.padding
    }
}
