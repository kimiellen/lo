pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.core

// 悬浮明细浮层：居中显示在顶栏下沿，visible 由调用方控制
PopupWindow {
    id: root

    required property Item targetItem
    property string title: ""
    property string detail: ""

    readonly property real gap: 4
    readonly property real contentWidth: frame.width
    readonly property real contentHeight: frame.height
    // 目标元素在窗口内的 y 坐标（用于把浮层挂到窗口下沿而不是元素下沿）
    readonly property real targetY: root.targetItem.mapToItem(null, 0, 0).y

    visible: false
    color: "transparent"

    anchor.item: root.targetItem
    anchor.rect.x: Math.round(root.targetItem.width / 2 - root.contentWidth / 2)
    anchor.rect.y: root.targetItem.Window.window
        ? root.targetItem.Window.window.height - root.targetY
        : root.targetItem.height
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.Slide

    implicitWidth: root.contentWidth
    implicitHeight: root.contentHeight + root.gap

    Rectangle {
        id: frame
        y: root.gap
        width: content.implicitWidth + 16
        height: content.implicitHeight + 10
        radius: 6
        color: Theme.panel
        border.width: 1
        border.color: Theme.trackDim

        Row {
            id: content
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: root.title
                color: Theme.subtext
                font.family: Theme.fontFamily
                font.pixelSize: 10
                renderType: Text.NativeRendering
            }

            Text {
                text: root.detail
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 11
                renderType: Text.NativeRendering
            }
        }
    }
}
